import AVFoundation
import UIKit
import Capacitor

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var multiScan: Bool = false
    var codes:[String] = []
    var codeCount: UILabel?
    var maxScans = 9999
    
    weak var delegate: BarcodeScannerDelegate?

    init(multi:Bool) {
        multiScan = multi
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("error")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr,.code128]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.connection?.videoOrientation = self.videoOrientationFromCurrentDeviceOrientation()
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        
        let redLine = UIView()
        redLine.backgroundColor = UIColor.red
        redLine.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 3)
        view.addSubview(redLine)
        animateRedLine(redLine: redLine,endY:view.bounds.height - 90 - 120)
        
        

        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
        
        if(multiScan){
            
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "xmark"), for: .normal)
            button.tintColor = .white
            button.backgroundColor = .clear
            button.frame = CGRect(x: 0, y: 0, width: 90, height: 90)
            button.center = CGPoint(x: view.bounds.midX, y: view.bounds.height - 90 - 45)
            button.layer.cornerRadius = button.frame.width / 2
            button.layer.borderWidth = 8
            button.layer.borderColor = UIColor.white.cgColor
            button.addTarget(self, action: #selector(exitBtnTap), for: .touchUpInside)
            view.addSubview(button)
            
            let resourceBundle = Bundle.module

            if let imgSrc = UIImage(named: "scan", in: resourceBundle, compatibleWith: nil) {
                let imageView = UIImageView(image: imgSrc)
                imageView.frame = CGRect(x: view.bounds.width - 90 - 16, y: view.bounds.height - 90 - 90, width: 90, height: 90)
                imageView.contentMode = .scaleAspectFit
                view.addSubview(imageView)
                
                let label = UILabel(frame: imageView.bounds)
                label.text = "0"
                label.textColor = .white
                label.font = UIFont.systemFont(ofSize: 48)
                label.textAlignment = .center
                imageView.addSubview(label)
                codeCount = label
            }else{
                print("*** No se encontró la imagen scan")
            }
            
            
        }

    }
    
    
    @objc func exitBtnTap() {
        delegate?.didFoundCodes(codes: codes)
        dismiss(animated: true)
    }
    
    
    func animateRedLine(redLine:UIView,endY:CGFloat) {
        UIView.animate(withDuration: 1.0, animations: {
                redLine.frame.origin.y = endY
            }) { _ in
                UIView.animate(withDuration: 1.0) {
                    redLine.frame.origin.y = 0
                } completion: { _ in
                    self.animateRedLine(redLine: redLine, endY: endY)
                }
            }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            self.previewLayer.connection?.videoOrientation = self.videoOrientationFromCurrentDeviceOrientation()

            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                // Finish Rotation
        })

        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func videoOrientationFromCurrentDeviceOrientation() -> AVCaptureVideoOrientation {
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            return AVCaptureVideoOrientation.portrait
        case .landscapeLeft:
            return AVCaptureVideoOrientation.landscapeLeft
        case .landscapeRight:
            return AVCaptureVideoOrientation.landscapeRight
        case .portraitUpsideDown:
            return AVCaptureVideoOrientation.portraitUpsideDown
        default:
            // Can this happen?
            return AVCaptureVideoOrientation.portrait
        }
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            DispatchQueue.global().async {
                self.captureSession.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool){
        if(multiScan){
            delegate?.didFoundCodes(codes: codes)
        }else{
            delegate?.didCancelled()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if(!multiScan){
            captureSession.stopRunning()

            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                showToast(message: stringValue)
                found(code: stringValue)
            }
            dismiss(animated: true)
            
        }else{
            for i in metadataObjects{
                guard let readableObj = i as? AVMetadataMachineReadableCodeObject else {continue}
                guard let stringValue = readableObj.stringValue else {continue}
                
                if(!codes.contains(stringValue)){
                    codes.append(stringValue)
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    showToast(message: stringValue)
                    if let labelcodeCount = codeCount{
                        labelcodeCount.text = codes.count.description
                    }
                    if(codes.count >= maxScans){
                        exitBtnTap()
                    }
                }
                
            }
        }
    }
    
    
    func showToast(message: String, duration: TimeInterval = 2.0) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.view.alpha = 0.6
        alertController.view.layer.cornerRadius = 15
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }

    func found(code: String) {
        delegate?.didFoundCode(code: code)
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}

