//
//  CaptureSdkHandler.swift
//  SingleEntry
//
//  Created by Cyrille on 13/10/2025.
//  Copyright © 2025 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import CaptureSDK

// All the CaptureHelperDelegate are grouped in a same class to simplify this sample app
// Otherwise those delegates can be "pushed" and "popped" for a particular class

class CaptureSdkHandler: NSObject, CaptureHelperDevicePresenceDelegate, CaptureHelperDeviceManagerPresenceDelegate, CaptureHelperDeviceDecodedDataDelegate, CaptureHelperErrorDelegate, CaptureHelperDevicePowerDelegate, CaptureHelperDeviceManagerDiscoveryDelegate {

    var scanners: [CaptureHelperDevice] = []

    
    // MARK: - CaptureHelperDevicePresenceDelegate

    // Notifies that a device has been connected
    func didNotifyArrivalForDevice(_ device: CaptureHelperDevice, withResult result:SKTResult) {
        print("didNotifyArrivalForDevice: \(device.deviceInfo.name ?? "") - Type: \(device.deviceInfo.deviceType) - Result: \(result.rawValue)")
        NotificationCenter.default.post(name: NSNotification.Name("didNotifyArrivalForDevice"), object: device)
    }

    // Notifies that a device has been disconnected
    func didNotifyRemovalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("didNotifyRemovalForDevice: \(device.deviceInfo.name ?? "") - Result: \(result.rawValue)")
        NotificationCenter.default.post(name: NSNotification.Name("didNotifyRemovalForDevice"), object: device)
    }

    // MARK: - CaptureHelperDeviceManagerPresenceDelegate

    // Notifies that the Bluetooth LE manager device has been initialized
    func didNotifyArrivalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        print("didNotifyArrivalForDeviceManager: \(device.deviceInfo.name ?? "") - Result: \(result.rawValue)")
        NotificationCenter.default.post(name: NSNotification.Name("didNotifyArrivalForDeviceManager"), object: device)
    }

    // Notifies that the Bluetooth LE manager device has been removed
    func didNotifyRemovalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        print("didNotifyRemovalForDeviceManager: \(device.deviceInfo.name ?? "") - Result: \(result.rawValue)")
    }

    // MARK: - CaptureHelperDeviceManagerDiscoveryDelegate

    // Notifies that the Bluetooth LE manager discovered a Bluetooth LE device. It can be triggered multiple times on the span of a discovery
    func didDiscoverDevice(_ device: SKTCaptureDiscoveredDeviceInfo, fromDeviceManager deviceManager: CaptureSDK.CaptureHelperDeviceManager) {
        print("didDiscoverDevice: Name: \(device.name ?? "") - ServiceUUID: \(device.serviceUuid ?? "") - Identifier: \(device.identifierUuid ?? "")")
        NotificationCenter.default.post(name: NSNotification.Name("didDiscoverDevice"), object: device)
    }
    
    // Notifies that the Bluetooth LE manager has finished to discover Bluetooth LE devices
    func didEndDiscoveryWithResult(_ result: SKTResult, fromDeviceManager deviceManager: CaptureSDK.CaptureHelperDeviceManager) {
        print("didEndDiscoveryWithResult: \(result.rawValue)")
        NotificationCenter.default.post(name: NSNotification.Name("didEndDiscoveryWithResult"), object: nil)
    }
    
    // MARK: - CaptureHelperDeviceDecodedDataDelegate

    // Notifies that data have been scanned
    func didReceiveDecodedData(_ decodedData: SKTCaptureDecodedData?, fromDevice device: CaptureSDK.CaptureHelperDevice, withResult result: SKTResult) {
        print("didReceiveDecodedData for device: \(device.deviceInfo.name ?? "") with result: \(result.rawValue)")
        if result == .E_NOERROR {
            if let rawData = decodedData!.decodedData {
                let rawDataSize = rawData.count
                print("Size: \(rawDataSize)")
                print("data: \(rawData)")
                let str = decodedData!.stringFromDecodedData()
                print("Decoded Data \(String(describing: str))")
                
                NotificationCenter.default.post(name: NSNotification.Name("didReceiveDecodedDataSuccess"), object: str)
                
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
        // This case is mainly for SocketCam when cancelling the scan
        } else if result == .E_CANCEL {
            NotificationCenter.default.post(name: NSNotification.Name("didReceiveDecodedDataCancel"), object: nil)
        }
    }
 
    // MARK: - CaptureHelperDevicePowerDelegate

    func didChangePowerState(_ powerState: SKTCapturePowerState, forDevice device: CaptureHelperDevice) {
        print("Receive a didChangePowerState \(powerState)")
    }
    
    func didChangeBatteryLevel(_ batteryLevel: Int, forDevice device: CaptureHelperDevice) {
        let battery = SKTHelper.getCurrentLevel(fromBatteryLevel: batteryLevel)
        print("the device \((device.deviceInfo.name)! as String) has a battery level: \(String(describing: battery))%")
    }

    // MARK: - CaptureHelperErrorDelegate

    func didReceiveError(_ error: SKTResult) {
        print("Receive a CaptureSDK error: \(error.rawValue)")
    }

}
