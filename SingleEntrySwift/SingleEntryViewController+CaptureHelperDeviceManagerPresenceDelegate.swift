//
//  SingleEntryViewController+CaptureHelperDeviceManagerPresenceDelegate.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 24.03.22.
//  Copyright © 2022 Socket Mobile, Inc. All rights reserved.
//

import CaptureSDK

extension SingleEntryViewController: CaptureHelperDeviceManagerPresenceDelegate {

    // THIS IS THE PLACE TO TURN ON THE Bluetooth Low Energy FEATURE SO THE NFC READER (S550 or S370) OR A BARCODE READER (S320) CAN
    // BE DISCOVERED AND CONNECT TO THIS APP
    func didNotifyArrivalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        print("--DEBUG-- device manager arrival notification: \(device.deviceInfo.name ?? "")")
        // this device property completion block might update UI
        // element, then we set its dispatchQueue here to this app
        // main thread
        device.dispatchQueue = DispatchQueue.main
        device.getFavoriteDevicesWithCompletionHandler { (result, favorites) in
            print("--DEBUG-- getting the favorite devices returned \(result.rawValue)")
            if result == .E_NOERROR {
                if let fav = favorites {
                    // if favorites is empty (meaning NFC reader auto-discovery is off)
                    // then set it to "*" to connect to any NFC reader in the vicinity
                    // To turn off the BLE auto reconnection, set the favorites to
                    // an empty string
                    if fav.isEmpty {
                        device.setFavoriteDevices("*;*;*;*;*;*;*;*;*;*;*", withCompletionHandler: { (result) in
                            print("--DEBUG-- setting new favorites returned \(result.rawValue)")
                        })
                    }
                }
            }
        }
    }

    func didNotifyRemovalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        print("--DEBUG-- didNotifyRemovalForDeviceManager: \(device.deviceInfo.name ?? "") in the detail view")
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
            }
        }
        if socketCamC860 != nil {
            if socketCamC860 == device {
                socketCamC860 = nil
            }
        }
        scanners = newScanners
        displayScanners()
    }

}
