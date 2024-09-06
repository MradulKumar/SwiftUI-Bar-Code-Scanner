//
//  ScannerView.swift
//  SwiftUI-BarcodeScanner
//
//  Created by Mradul Kumar  on 03/09/24.
//

import UIKit
import SwiftUI

struct ScannerView: UIViewControllerRepresentable {
    
    @Binding var scannedCode: String
    @Binding var alertItem: AlertItem?
    
    func makeUIViewController(context: Context) -> ScannerVC {
        ScannerVC(scannerVCDelegate: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: ScannerVC, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(scannerView: self)
    }
    
    final class Coordinator: NSObject, ScannerVCDelegate {
        
        private let scannerView: ScannerView
        
        init(scannerView: ScannerView) {
            self.scannerView = scannerView
        }
        
        func didFind(barcode: String) {
            self.scannerView.scannedCode = barcode
            print("scanned barcode : \(barcode)")
        }
        
        func didSurface(error: CameraError) {
            switch error {
            case .invalidDeviceInput:
                self.scannerView.alertItem = AlertContext.invalidDeviceInput
            case .invalidScannedInput:
                self.scannerView.alertItem = AlertContext.invalidScanType
            }
            print("error : \(error.rawValue)")
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView(scannedCode: .constant("Test Preview"), alertItem: .constant(nil))
    }
}
