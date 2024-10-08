//
//  SingleEntryViewController+CaptureHelperDelegate.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 24.03.22.
//  Copyright © 2022 Socket Mobile, Inc. All rights reserved.
//

import CaptureSDK


extension SingleEntryViewController: CaptureHelperDevicePresenceDelegate {

    // since we use CaptureHelper in shared mode, we receive a device Arrival
    // each time this view becomes active and there is a scanner connected
    func didNotifyArrivalForDevice(_ device: CaptureHelperDevice, withResult result:SKTResult) {
        print("--DEBUG-- didNotifyArrivalForDevice: \(device.deviceInfo.name ?? "") - Type: \(device.deviceInfo.deviceType) in the detail view")
        if device.deviceInfo.deviceType == .socketCamC820 {
            socketCamTriggerC820?.isHidden = false
            socketCamTriggerC820Custom?.isHidden = false
            socketCamC820 = device
        } else if device.deviceInfo.deviceType == .socketCamC860 {
            socketCamTriggerC860?.isHidden = false
            socketCamTriggerC860Custom?.isHidden = false
            socketCamC860 = device
        } else {
            lastDeviceConnected = device
        }

        scanners.append(device.deviceInfo.name!)
        displayScanners()
    }

    func didNotifyRemovalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("--DEBUG-- didNotifyRemovalForDevice: \(device.deviceInfo.name ?? "") in the detail view")
        var newScanners : [String] = []
        for scanner in scanners{
            if(scanner as String != device.deviceInfo.name){
                newScanners.append(scanner as String)
            }
        }
        // if the scanner that is removed is SocketCam then
        // we nil its reference
        if socketCamC820 != nil {
            if socketCamC820 == device {
                socketCamC820 = nil
                socketCamTriggerC820?.isHidden = true;
                socketCamTriggerC820Custom?.isHidden = true;
            }
        }
        if socketCamC860 != nil {
            if socketCamC860 == device {
                socketCamC860 = nil
                socketCamTriggerC860?.isHidden = true;
                socketCamTriggerC860Custom?.isHidden = true;
            }
        }
        scanners = newScanners
        displayScanners()
    }

}
