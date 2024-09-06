//
//  ScannerVC.swift
//  SwiftUI-BarcodeScanner
//
//  Created by Mradul Kumar  on 03/09/24.
//

import Foundation
import AVFoundation
import UIKit

enum CameraError: String {
    case invalidDeviceInput = "Something is wrong with the camera."
    case invalidScannedInput = "Value scanned is not valid. This app scans ean8 or ean13 only."
}

protocol ScannerVCDelegate: AnyObject {
    func didFind(barcode: String)
    func didSurface(error: CameraError)
}

final class ScannerVC: UIViewController {
    
    let captureSession: AVCaptureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var scannerDelegate: ScannerVCDelegate!
    
    init(scannerVCDelegate: ScannerVCDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.scannerDelegate = scannerVCDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCpatureSession()
        self.view.backgroundColor = .black
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let previewLayer = previewLayer else {
            scannerDelegate?.didSurface(error: CameraError.invalidDeviceInput)
            return
        }
        
        previewLayer.frame = view.layer.bounds
    }
    
    private func setupCpatureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            scannerDelegate?.didSurface(error: CameraError.invalidDeviceInput)
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            scannerDelegate?.didSurface(error: CameraError.invalidDeviceInput)
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            scannerDelegate?.didSurface(error: CameraError.invalidDeviceInput)
            return
        }
        
        let metaDataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metaDataOutput) {
            captureSession.addOutput(metaDataOutput)
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDataOutput.metadataObjectTypes = [.ean8, .ean13]
        } else {
            scannerDelegate?.didSurface(error: CameraError.invalidDeviceInput)
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
        
        captureSession.startRunning()
    }
}

extension ScannerVC: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let obj = metadataObjects.first else {
            scannerDelegate?.didSurface(error: CameraError.invalidScannedInput)
            return
        }
        
        guard let readableObj = obj as? AVMetadataMachineReadableCodeObject else {
            scannerDelegate?.didSurface(error: CameraError.invalidScannedInput)
            return
        }
        
        guard let barcode = readableObj.stringValue else {
            scannerDelegate?.didSurface(error: CameraError.invalidScannedInput)
            return
        }
        
        captureSession.stopRunning()

        scannerDelegate?.didFind(barcode: barcode)        
    }
}
