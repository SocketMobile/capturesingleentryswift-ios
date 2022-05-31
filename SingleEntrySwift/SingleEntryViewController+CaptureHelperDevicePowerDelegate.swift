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
        print("Receive a didChangeBatteryLevel \(batteryLevel)")
        statusLabel?.text = "Status: Battery: \(batteryLevel)"
    }
    
}
