import Foundation
import Capacitor
import AVFoundation


@objc(BarcodeScannerPlugin)
public class BarcodeScannerPlugin: CAPPlugin, CAPBridgedPlugin, BarcodeScannerDelegate {

    public let identifier = "BarcodeScannerPlugin"
    public let jsName = "BarcodeScanner"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "scan", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "multiScan", returnType: CAPPluginReturnPromise)
    ]

    var call: CAPPluginCall?
    var barcodeScanner: BarcodeScannerViewController?

    @objc func scan(_ call: CAPPluginCall) {
        showScanner(call: call, multi: false)
    }

    @objc func multiScan(_ call: CAPPluginCall) {
        showScanner(call: call, multi: true)
    }

    func showScanner(call: CAPPluginCall, multi: Bool = false) {
        call.keepAlive = true
        self.call = call

        if let isSim = bridge?.isSimEnvironment, isSim || !UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            call.reject("Camera not available while running in Simulator")
            return
        }

        DispatchQueue.main.async {
            self.barcodeScanner = BarcodeScannerViewController(multi: multi)
            self.barcodeScanner!.delegate = self
            let maxScans = call.getInt("maxScans", 9999)
            self.barcodeScanner!.maxScans = maxScans
        }

        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.main.async {
                    self.bridge?.viewController?.present(self.barcodeScanner!, animated: true, completion: nil)
                }
            } else {
                call.reject("User denied access to camera")
            }
        }
    }

    func didCancelled() {
        self.call?.resolve(["result": false])
    }

    func didFoundCode(code: String) {
        self.call?.resolve(["result": true, "code": code])
    }

    func didFoundCodes(codes: [String]) {
        let result = codes.count > 0
        self.call?.resolve([
            "result": result,
            "codes": codes,
            "count": codes.count
        ])
    }
}
