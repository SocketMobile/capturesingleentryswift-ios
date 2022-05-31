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
        print("didNotifyArrivalForDevice in the detail view")
        let name = device.deviceInfo.name
        if(name?.caseInsensitiveCompare("socketCam") == ComparisonResult.orderedSame){
            socketCamTrigger?.isHidden = false;
            socketCamContinuousScan?.isHidden = false;
            socketCam = device
            
            // set the Overlay View context to give a reference to this controller
            if let scanner = socketCam {
                let context : [String:Any] = [SKTCaptureSocketCamContext : self]
                
                scanner.setSocketCamOverlayViewParameter(context, withCompletionHandler: { (result) in
                    self.displayAlertForResult(result, forOperation: "SetOverlayView")
                })
            }
        }
        else {
            lastDeviceConnected = device
            socketCamTrigger?.isHidden = false;
            socketCamContinuousScan?.isHidden = false;
        }
        scanners.append(device.deviceInfo.name!)
        displayScanners()
    }

    func didNotifyRemovalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("didNotifyRemovalForDevice in the detail view")
        var newScanners : [String] = []
        for scanner in scanners{
            if(scanner as String != device.deviceInfo.name){
                newScanners.append(scanner as String)
            }
        }
        // if the scanner that is removed is SocketCam then
        // we nil its reference
        if socketCam != nil {
            if socketCam == device {
                socketCam = nil
            }
        }
        scanners = newScanners
        displayScanners()
    }

}
