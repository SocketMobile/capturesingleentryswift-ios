//
//  SingleEntry+CaptureHelperDelegate.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 24.03.22.
//  Copyright © 2022 Socket Mobile, Inc. All rights reserved.
//

import CaptureSDK


extension SingleEntry: CaptureHelperDevicePresenceDelegate {

    // since we use CaptureHelper in shared mode, we receive a device Arrival
    // each time this view becomes active and there is a scanner connected
    func didNotifyArrivalForDevice(_ device: CaptureHelperDevice, withResult result:SKTResult) {
        print("didNotifyArrivalForDevice")

        if device.deviceInfo.deviceType == .socketCamC820 {
            socketCam = device

            // set the Overlay View context to give a reference to this controller
            if let scanner = SingleEntry.shared.socketCam, let delegate = delegate as? SingleEntryViewController {
                let context : [String: Any] = [SKTCaptureSocketCamContext : delegate]

                scanner.setSocketCamOverlayViewParameter(context, withCompletionHandler: { (result) in
                    print("result for operation SetOverlayView: \(result.rawValue)")
                })
            }

            items.append(.socketCam)
        } else {
            if device.deviceInfo.deviceType == .NFCS370 || device.deviceInfo.deviceType == .scannerS550 {
                nfcDevice = device
                if !items.contains(.deviceThemes) {
                    items.append(.deviceThemes)
                }
            } else if device.deviceInfo.deviceType == .scannerS370 {
                barcodeDevice = device
            } else {
                barcodeDevice = device
            }
            scanners.append(device.deviceInfo.name!)

            if !items.contains(.deviceTrigger) {
                items.append(.deviceTrigger)
            }
            if !items.contains(.devicePower) {
                items.append(.devicePower)
            }
        }

        delegate?.notifyDevicePresence()
    }

    func didNotifyRemovalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("didNotifyRemovalForDevice")

        var newScanners : [String] = []
        for scanner in scanners {
            if scanner as String != device.deviceInfo.name {
                newScanners.append(scanner as String)
            }
        }

        // if the scanner that is removed is SocketCam then we nil its reference
        if socketCam != nil && socketCam == device {
            socketCam = nil
        }
        
        if nfcDevice == device {
            nfcDevice = nil
        }
        if barcodeDevice ==  device {
            barcodeDevice = nil
        }
        
        if nfcDevice == nil {
            if items.contains(.deviceThemes) {
                let index = items.firstIndex(of: .deviceThemes)
                items.remove(at: index!)
            }
        }

        if nfcDevice == nil && barcodeDevice == nil {
            if items.contains(.deviceTrigger) {
                let index = items.firstIndex(of: .deviceTrigger)
                items.remove(at: index!)
            }
            if items.contains(.devicePower) {
                let index = items.firstIndex(of: .devicePower)
                items.remove(at: index!)
            }
        }

        scanners = newScanners

        delegate?.notifyDevicePresence()
    }

}
