package cl.kgames.capacitorbarcodescanner

import android.Manifest
import android.annotation.SuppressLint
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Bundle
import android.os.Vibrator
import android.util.DisplayMetrics
import android.util.Log
import android.view.View
import android.view.animation.Animation
import android.view.animation.AnimationUtils
import android.widget.ImageButton
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import com.google.android.material.button.MaterialButton

import com.google.mlkit.vision.barcode.BarcodeScanner
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.common.InputImage
import java.lang.Math.*
import java.util.concurrent.Executors


class ScannerActivity : AppCompatActivity() {

    private var previewView: PreviewView? = null
    private var cameraProvider: ProcessCameraProvider? = null
    private var cameraSelector: CameraSelector? = null
    private var lensFacing = CameraSelector.LENS_FACING_BACK
    private var previewUseCase: Preview? = null
    private var analysisUseCase: ImageAnalysis? = null

    private var resultCode:String = ""
    private var resultCodes: Array<String> = arrayOf()
    private var multiScan:Boolean = false;
    private var codesCounter: TextView? = null
    private var maxScans:Int = 9999


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_scanner)
        setupCamera()
        val aniSlide: Animation =
            AnimationUtils.loadAnimation(this@ScannerActivity, R.anim.scanner_animation)
        var barLine: View = findViewById(R.id.barcode_line)
        barLine.startAnimation(aniSlide)

        val intent = intent
        if (intent != null) {
            val valor = intent.getBooleanExtra("multi",false)
            if (valor != null) {
                multiScan = valor
            }

            val maxReadsArg = intent.getIntExtra("maxScans",9999)
            maxScans = maxReadsArg
        }
        val imageButton: ImageButton = findViewById(R.id.btn_ok)
        codesCounter = findViewById(R.id.codes_counter)

        imageButton.setOnClickListener{
            closeActivity("")
        }
        if(multiScan){
            imageButton.visibility = View.VISIBLE
            codesCounter?.visibility = View.VISIBLE
        }
    }


    override fun finish() {
        val data = Intent()

        if(!multiScan){
            data.putExtra("code", resultCode)

        }else{
            data.putExtra("codes",resultCodes);
            data.putExtra("multi",true)
        }

        setResult(RESULT_OK, data)
        super.finish()
    }

    private fun closeActivity(value:String){
        resultCode = value;
        finish()
    }


    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        if (requestCode == PERMISSION_CAMERA_REQUEST) {
            if (isCameraPermissionGranted()) {
                bindCameraUseCases()
            } else {
                closeActivity("")
            }
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    private fun isCameraPermissionGranted(): Boolean {
        return ContextCompat.checkSelfPermission(
            baseContext,
            Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun setupCamera() {
        previewView = findViewById(R.id.preview_view)
        cameraSelector = CameraSelector.Builder().requireLensFacing(lensFacing).build()

        ViewModelProvider(
            this, ViewModelProvider.AndroidViewModelFactory.getInstance(application)
        ).get(CameraXViewModel::class.java)
            .processCameraProvider
            .observe(this, Observer { provider: ProcessCameraProvider?->
                cameraProvider = provider
                if (isCameraPermissionGranted()) {
                    bindCameraUseCases()
                } else {
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.CAMERA),
                        PERMISSION_CAMERA_REQUEST
                    )
                }
            }
            )
    }


    private fun bindPreviewUseCase() {
        if (cameraProvider == null) {
            return
        }
        if (previewUseCase != null) {
            cameraProvider!!.unbind(previewUseCase)
        }

        previewUseCase = Preview.Builder()
            .setTargetAspectRatio(screenAspectRatio)
            .setTargetRotation(getWindowManager().getDefaultDisplay().getRotation())
            .build()
        previewUseCase!!.setSurfaceProvider(previewView!!.createSurfaceProvider())

        try {
            cameraProvider!!.bindToLifecycle(/* lifecycleOwner= */this,
                cameraSelector!!,
                previewUseCase
            )
        } catch (ex: RuntimeException) {
            Log.e(TAG, ex.message.toString())
        }
    }

    private fun bindCameraUseCases() {
        bindPreviewUseCase()
        bindAnalyseUseCase()
    }

    private fun bindAnalyseUseCase() {

        val options = BarcodeScannerOptions.Builder()
                .setBarcodeFormats(
                        Barcode.FORMAT_QR_CODE,
                        Barcode.FORMAT_CODE_128)
                .build()

        val barcodeScanner: BarcodeScanner = BarcodeScanning.getClient(options)


        if (cameraProvider == null) {
            return
        }
        if (analysisUseCase != null) {
            cameraProvider!!.unbind(analysisUseCase)
        }

        analysisUseCase = ImageAnalysis.Builder()
            .setTargetAspectRatio(screenAspectRatio)
            .setTargetRotation(getWindowManager().getDefaultDisplay().getRotation())
            .build()

        val cameraExecutor = Executors.newSingleThreadExecutor()

        analysisUseCase?.setAnalyzer(
            cameraExecutor,
            ImageAnalysis.Analyzer { imageProxy ->
                processImageProxy(barcodeScanner, imageProxy)
            }
        )

        try {
            cameraProvider!!.bindToLifecycle(
                /* lifecycleOwner= */this,
                cameraSelector!!,
                analysisUseCase
            )
        } catch (illegalStateException: IllegalStateException) {
            Log.e(TAG, illegalStateException.message ?: "IllegalStateException")
        } catch (illegalArgumentException: IllegalArgumentException) {
            Log.e(TAG, illegalArgumentException.message ?: "IllegalArgumentException")
        }
    }

    @SuppressLint("UnsafeExperimentalUsageError")
    private fun processImageProxy(
        barcodeScanner: BarcodeScanner,
        imageProxy: ImageProxy
    ) {
        val inputImage =
            InputImage.fromMediaImage(imageProxy.image!!, imageProxy.imageInfo.rotationDegrees)

        barcodeScanner.process(inputImage)
            .addOnSuccessListener { barcodes ->
                if(barcodes.size > 0){
                    if(!multiScan){
                        val code = barcodes[0]
                        val codeStr = extractCodeValue(code)
                        if(codeStr != null){
                          closeActivity(codeStr)
                        }else {
                          Log.w(TAG, "CÃ³digo escaneado sin contenido legible (rawValue/displayValue null)")
                        }

                    }else{
                        for (i in barcodes){
                            val codeValue = extractCodeValue(i) ?: continue
                            if(!resultCodes.contains(codeValue)){
                                popReaded(codeValue)
                                resultCodes+=codeValue
                                codesCounter!!.text = resultCodes.count().toString()

                                if(resultCodes.size >= maxScans){
                                    closeActivity(codeValue)
                                }
                            }
                        }
                    }
                }
            }
            .addOnFailureListener {

                Log.e(TAG,"Error al leer")
                Log.e(TAG, it.message ?: it.toString())
            }.addOnCompleteListener {
                imageProxy.close()
            }
    }


    private fun popReaded(value:String){
        Toast.makeText(this, value, Toast.LENGTH_SHORT).show()
    }

    private fun extractCodeValue(code: Barcode): String? {
        return code.rawValue
        ?: code.displayValue
    }

    private val screenAspectRatio: Int
        get() {
            val metrics = DisplayMetrics()
            return aspectRatio(metrics.widthPixels, metrics.heightPixels)
        }

    private fun aspectRatio(width: Int, height: Int): Int {
        val previewRatio = max(width, height).toDouble() / min(width, height)
        if (abs(previewRatio - RATIO_4_3_VALUE) <= abs(previewRatio - RATIO_16_9_VALUE)) {
            return AspectRatio.RATIO_4_3
        }
        return AspectRatio.RATIO_16_9
    }

    companion object {
        private val TAG = ScannerActivity::class.simpleName
        private const val PERMISSION_CAMERA_REQUEST = 1

        private const val RATIO_4_3_VALUE = 4.0 / 3.0
        private const val RATIO_16_9_VALUE = 16.0 / 9.0
    }
}