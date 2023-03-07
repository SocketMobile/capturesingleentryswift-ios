//
//  SingleEntry.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 17.02.23.
//  Copyright © 2023 Socket Mobile, Inc. All rights reserved.
//

import CaptureSDK
import Foundation
import UIKit


protocol SingleEntryDelegate: NSObject {

    func notifyDevicePresence()
    func notifyDeviceManagerPresence()
    func notifyDecodedDataString(dataString: String)
    func notifyPowerState(_ powerState: SKTCapturePowerState)
    func notifyBatteryLevel(_ batteryLevel: Int)
    func notifyError(_ error: SKTResult)

}

class SingleEntry: NSObject {
    
    static let shared = SingleEntry()
    
    weak var delegate: SingleEntryDelegate?

    var scanners : [String] = []  // keep a list of scanners to display in the status
    var socketCam : CaptureHelperDevice?  // keep a reference on SocketCam
    
    let noScannerConnected = "No scanner connected"
    var nfcDevice: CaptureHelperDevice?
    var barcodeDevice: CaptureHelperDevice?

    var items: [ListItem] = [.settings]

}

enum ListItem {
    case settings, socketCam, deviceThemes, deviceTrigger, devicePower
}

