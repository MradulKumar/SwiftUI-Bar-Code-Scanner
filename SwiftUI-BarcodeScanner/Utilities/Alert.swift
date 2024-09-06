//
//  Alert.swift
//  SwiftUI-BarcodeScanner
//
//  Created by Mradul Kumar  on 03/09/24.
//

import Foundation
import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let dismissButton: Alert.Button
}

struct AlertContext {
    static let invalidDeviceInput = AlertItem(title: "Invalid Device Input",
                                              message: "Something is wrong with the camera.",
                                              dismissButton: Alert.Button.default(Text("Ok")))
    
    static let invalidScanType = AlertItem(title: "Invalid Scan Type",
                                           message: "Value scanned is not valid. This app scans EAN-8 or EAN-13 only.",
                                           dismissButton: Alert.Button.default(Text("Ok")))
}
