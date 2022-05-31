//
//  SingleEntryViewController+CaptureHelperDeviceManagerPresenceDelegate.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 24.03.22.
//  Copyright © 2022 Socket Mobile, Inc. All rights reserved.
//

import CaptureSDK

extension SingleEntryViewController: CaptureHelperDeviceManagerPresenceDelegate {

    // THIS IS THE PLACE TO TURN ON THE BLE FEATURE SO THE NFC READER CAN
    // BE DISCOVERED AND CONNECT TO THIS APP
    func didNotifyArrivalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        print("device manager arrival notification")
        // this device property completion block might update UI
        // element, then we set its dispatchQueue here to this app
        // main thread
        device.dispatchQueue = DispatchQueue.main
        device.getFavoriteDevicesWithCompletionHandler { (result, favorites) in
            print("getting the favorite devices returned \(result.rawValue)")
            if result == .E_NOERROR {
                if let fav = favorites {
                    // if favorites is empty (meaning NFC reader auto-discovery is off)
                    // then set it to "*" to connect to any NFC reader in the vicinity
                    // To turn off the BLE auto reconnection, set the favorites to
                    // an empty string
                    if fav.isEmpty {
                        device.setFavoriteDevices("*", withCompletionHandler: { (result) in
                            print("setting new favorites returned \(result.rawValue)")
                        })
                    }
                }
            }
        }
    }

    func didNotifyRemovalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
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
//                socketCam = nil
            }
        }
        scanners = newScanners
        displayScanners()
    }

}
