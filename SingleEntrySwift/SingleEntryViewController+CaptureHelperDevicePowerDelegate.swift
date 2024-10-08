//
//  SingleEntryViewController+CaptureHelperDevicePowerDelegate.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 24.03.22.
//  Copyright © 2022 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import CaptureSDK

extension SingleEntryViewController: CaptureHelperDevicePowerDelegate {
    
    func didChangePowerState(_ powerState: SKTCapturePowerState, forDevice device: CaptureHelperDevice) {
        print("Receive a didChangePowerState \(powerState)")
    }
    
    func didChangeBatteryLevel(_ batteryLevel: Int, forDevice device: CaptureHelperDevice) {
        let arrayOfBytes = withUnsafeBytes(of: batteryLevel.littleEndian, Array.init)
        print("Receive a didChangeBatteryLevel \(String(describing: batteryLevel)) => Current value: \(arrayOfBytes[1])%")
        let batteryLevel = "Status: Battery: \(arrayOfBytes[1])%"

        statusLabel?.text = batteryLevel
    }
    
}
