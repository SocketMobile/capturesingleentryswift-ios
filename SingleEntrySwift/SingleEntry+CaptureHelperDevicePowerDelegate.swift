//
//  SingleEntry+CaptureHelperDevicePowerDelegate.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 24.03.22.
//  Copyright © 2022 Socket Mobile, Inc. All rights reserved.
//

import CaptureSDK


extension SingleEntry: CaptureHelperDevicePowerDelegate {

    func didChangePowerState(_ powerState: SKTCapturePowerState, forDevice device: CaptureHelperDevice) {
        print("Receive a didChangePowerState \(powerState)")
        delegate?.notifyPowerState(powerState)
    }

    func didChangeBatteryLevel(_ batteryLevel: Int, forDevice device: CaptureHelperDevice) {
        print("Receive a didChangeBatteryLevel \(batteryLevel)")
//        statusLabel?.text = "Status: Battery: \(batteryLevel)"
        delegate?.notifyBatteryLevel(batteryLevel)
    }

}
