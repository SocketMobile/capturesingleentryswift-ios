//
//  SettingsViewController.swift
//  SingleEntrySwift
//
//  Created by Eric Glaenzer on 10/27/15.
//  Copyright © 2015 Socket Mobile, Inc. All rights reserved.
//

import UIKit
import CaptureSDK

class SettingsViewController: UIViewController, CaptureHelperDevicePresenceDelegate, CaptureHelperDeviceManagerPresenceDelegate{
    var detailItem: AnyObject?
    var deviceManager: CaptureHelperDeviceManager?

    @IBOutlet weak var socketCamSwitch: UISwitch!
    @IBOutlet weak var captureVersion: UILabel!
    @IBOutlet weak var nfSupportSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // retrieve the current status of SocketCam
        let capture = CaptureHelper.sharedInstance

        capture.getSocketCamStatusWithCompletionHandler( {(result, socketCamStatus) in
            print("getSocketCamStatusWithCompletionHandler received!")
            print("Result:", result.rawValue)
            if result == SKTCaptureErrors.E_NOERROR {
                let status = socketCamStatus
                print("receive SocketCam status:",status ?? .disable)
                if status == .enable {
                    self.socketCamSwitch.isOn = true
                } else {
                    self.socketCamSwitch.isOn = false
                    if status == .notSupported {
                        capture.setSocketCamStatus(.supported, withCompletionHandler: { (result) in
                          print("setting SocketCam to supported returned \(result.rawValue)")
                        })
                    }
                }
            }
        })
        
        // ask for the Capture version
        CaptureHelper.sharedInstance.getVersionWithCompletionHandler({ (result, version) in
            print("getCaptureVersion completion received!")
            print("Result:", result.rawValue)
            if result == SKTCaptureErrors.E_NOERROR {
                let major = String(format:"%d",(version?.major)!)
                let middle = String(format:"%d",(version?.middle)!)
                let minor = String(format:"%d",(version?.minor)!)
                let build = String(format:"%d",(version?.build)!)
                print("receive Capture version: \(major).\(middle).\(minor).\(build)")
                self.captureVersion.text = "Capture Version: \(major).\(middle).\(minor).\(build)"
            }
        })
        
        // check the NFC support
        if let dm = deviceManager {
            dm.getFavoriteDevicesWithCompletionHandler({ (result, favorites) in
                print("getting the Device Manager favorites returns \(result.rawValue)")
                if result == SKTCaptureErrors.E_NOERROR {
                    if let fav = favorites {
                        self.nfSupportSwitch.isOn = !fav.isEmpty
                    }
                }
            })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        CaptureHelper.sharedInstance.pushDelegate(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        CaptureHelper.sharedInstance.popDelegate(self)
    }

    @IBAction func changeSocketCam(_ sender: AnyObject) {
        if(!socketCamSwitch.isOn){
            print("disabling SocketCam...")
            CaptureHelper.sharedInstance.setSocketCamStatus(.disable, withCompletionHandler: { (result) in
              print("disabling SocketCam returned \(result.rawValue)")
            })
        }
        else{
            print("enabling SocketCam...")
            CaptureHelper.sharedInstance.setSocketCamStatus(.enable, withCompletionHandler: { (result) in
                print("enabling SocketCam returned \(result.rawValue)")
            })
        }
    }
    
    @IBAction func changeNFCSupport(_ sender: UISwitch) {
        let deviceManagers = CaptureHelper.sharedInstance.getDeviceManagers()
        for d in deviceManagers {
            deviceManager = d
        }
        if let dm = deviceManager {
            if !nfSupportSwitch.isOn {
                print("turn off the NFC support...")
                dm.setFavoriteDevices("", withCompletionHandler: { (result) in
                    print("turning off NFC support returns \(result.rawValue)")
                })
            }
            else {
                print("turn on the NFC support...")
                dm.setFavoriteDevices("*", withCompletionHandler: { (result) in
                    print("turning off NFC support returns \(result.rawValue)")
                })
            }
        }
        else {
            nfSupportSwitch.isEnabled = false
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - CaptureHelper Delegates
    /**
    * called each time a device connects to the host
    * @param result contains the result of the connection
    * @param newDevice contains the device information
    */
    func didNotifyArrivalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("Settings: Device Arrival")
    }
    
    /**
    * called each time a device disconnect from the host
    * @param deviceRemoved contains the device information
    */
    func didNotifyRemovalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("Settings: Device Removal")
    }
    
    func didNotifyArrivalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        print("Settings: Device Manager Arrival")
        deviceManager = device
        deviceManager?.getFavoriteDevicesWithCompletionHandler({ (result, favorites) in
            if result == SKTCaptureErrors.E_NOERROR {
                self.nfSupportSwitch.isOn = !favorites!.isEmpty
            }
        })
    }
    
    func didNotifyRemovalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        print("Settings: Device Manager Removal")
        deviceManager = nil
    }
}
