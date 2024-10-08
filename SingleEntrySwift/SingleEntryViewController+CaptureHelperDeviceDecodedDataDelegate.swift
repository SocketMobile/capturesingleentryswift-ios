//
//  SingleEntryViewController+CaptureHelperDeviceDecodedDataDelegate.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 24.03.22.
//  Copyright © 2022 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import CaptureSDK

extension SingleEntryViewController: CaptureHelperDeviceDecodedDataDelegate {
    
    // This delegate is called each time a decoded data is read from the scanner
    // It has a result field that should be checked before using the decoded
    // data.
    // It would be set to SKTCaptureErrors.E_CANCEL if the user taps on the
    // cancel button in the SocketCam View Finder
    func didReceiveDecodedData(_ decodedData: SKTCaptureDecodedData?, fromDevice device: CaptureHelperDevice, withResult result:SKTResult) {
        print("didReceiveDecodedData in the detail view with result: \(result.rawValue)")
        print("->>> didReceiveDecodedData for device: \(device.deviceInfo.deviceType)")
        if result == .E_NOERROR {
            if let rawData = decodedData!.decodedData {
                let rawDataSize = rawData.count
                print("Size: \(rawDataSize)")
                print("data: \(rawData)")
                let str = decodedData!.stringFromDecodedData()
                print("Decoded Data \(String(describing: str))")
                DispatchQueue.main.async {
                    self.decodedData?.text = str
                    self.socketCamViewController?.dismiss(animated: true, completion: {
                        self.socketCamViewController = nil
                    })
                    self.socketCamViewController?.view.removeFromSuperview()
                    self.customView?.isHidden = true
                }
                // this code can be removed if the application is not interested by              
                // the host Acknowledgment for the decoded data
                #if HOST_ACKNOWLEDGMENT
                    device.setDataConfirmationWithLed(SKTCaptureDataConfirmationLed.green, withBeep:SKTCaptureDataConfirmationBeep.good, withRumble: SKTCaptureDataConfirmationRumble.good, withCompletionHandler: {(result) in
                        if result != .E_NOERROR {
                            print("error trying to confirm the decoded data: \(result.rawValue)")
                        }
                    })
                #endif
            }
        } else if result == .E_CANCEL {
            DispatchQueue.main.async {
                self.socketCamViewController?.view.removeFromSuperview()
                self.socketCamViewController = nil
                self.customView?.isHidden = true
            }
        }
    }

}
