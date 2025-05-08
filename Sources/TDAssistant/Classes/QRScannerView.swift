//
//  QRScannerView.swift
//  Copyright © 2024 Telus Digital. All rights reserved.
//

import UIKit
import AVFoundation

/// Delegate callback for the QRScannerView.
protocol QRScannerViewDelegate: AnyObject {
    func qrScanningDidFail()
    func qrScanningSucceededWithCode(_ str: String?)
    func qrScanningDidStop()
}

class QRScannerView: UIView {

    weak var delegate: QRScannerViewDelegate?

    var captureSession: AVCaptureSession?

    private var previewLayer: AVCaptureVideoPreviewLayer?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    deinit {
        stopScanning()
        previewLayer?.removeFromSuperlayer()
    }

    var isRunning: Bool {
        return captureSession?.isRunning ?? false
    }

    func startScanning() {
        DispatchQueue.main.async { // Ensure thread safety
            self.captureSession?.startRunning()
        }
    }

    func stopScanning() {
        DispatchQueue.main.async { // Ensure thread safety
            self.captureSession?.stopRunning()
        }
        delegate?.qrScanningDidStop()
    }

    func setupCaptureSession() {
        clipsToBounds = true
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            scanningDidFail()
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)

            if captureSession?.canAddInput(videoInput) ?? false {
                captureSession?.addInput(videoInput)
            } else {
                scanningDidFail()
                return
            }
        } catch {
            print("Error initializing camera input: \(error)")
            scanningDidFail()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession?.canAddOutput(metadataOutput) ?? false {
            captureSession?.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            scanningDidFail()
            return
        }

        setupPreviewLayer()

        DispatchQueue.main.async { // Ensure thread safety
            self.captureSession?.startRunning()
        }
    }

    private func setupPreviewLayer() {
        guard let session = captureSession else { return }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = self.bounds
        previewLayer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }

    func scanningDidFail() {
        delegate?.qrScanningDidFail()
        captureSession = nil
    }

    func found(code: String) {
        delegate?.qrScanningSucceededWithCode(code)
    }
}

extension QRScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        stopScanning()

        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
}
