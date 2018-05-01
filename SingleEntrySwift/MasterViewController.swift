//
//  MasterViewController.swift
//  SingleEntrySwift
//
//
//  NEW SUPPORT FOR SOCKET D600 (USING BLE)
//  =======================================
//  IN ORDER TO SUPPORT THE SOCKET D600 READER USING BLE
//  DERIVE THE VIEW CONTROLLER FROM CaptureHelperDeviceManagerPresenceDelegate
//  TO RECEIVE THE NOTIFICATION WHEN BLE MANAGER IS READY.
//  THEN IF THERE IS NO FAVORITE DEVICES, THERE WONT BE ANY BLE DISCOVERY
//  IN ORDER TO DISCOVER AND CONNECT TO A SOCKET D600, SET THE FAVORITE DEVICES
//  TO "*". IF A SOCKET D600 IS IN RANGE CAPTURE WILL AUTOMATICALLY CONNECT TO IT
//  AND REPLACE THE FAVORITE DEVICES BY THIS D600 DEVICE IDENTIFIER. SO THE NEXT
//  TIME THE DEVICE IS ON AND IN RANGE IT WILL AUTOMATICALLY CONNECT TO THIS PARTICULAR
//  D600.
//  IF BLE IS NO LONGER REQUIRED, THEN SETTING THE FAVORITE DEVICES TO AN EMPTY STRING
//  WILL AUTOMATICALLY STOP ANY BLE OPERATION.
//
//  THE BLE MANAGER SUPPORTS METHODS FOR DOING A MANUAL BLE SCAN DISCOVERY WHICH
//  COULD BE USE FOR SELECTING A PARTICULAR D600 BEFORE CONNECTING TO IT.
//
//
//  SOCKET BARCODE READERS USING BLUETOOTH CLASSIC
//  ==============================================
//  MAKE SURE THERE IS com.socketmobile.chs in the Supported external accessory protocols
//  IN THE PROJECT INFO
//
//  NOTE ABOUT THE HOST ACKNOWLEDGMENT
//  This sample app shows how the Host application can Acknowledge the decoded data
//  To activate this feature go to the project settings and in the "Other Swift Flags"
//  rename this "-DNO_HOST_ACKNOWLEDGMENT" to this "-DHOST_ACKNOWLEDGMENT"
//  If your application does not require Acknowledgment then every thing that is related
//  to configuring Capture or the Scanner for Local Acknowledgment can be safely ignored
//  because the Scanner comes setup to Local Acknowledgment by default. (Local Acknowledgment
//  means the decoded data gets acknowledged in the Scanner, and then they are sent to the host).
//
// Created by Eric Glaenzer on 11/17/14.
// Copyright 2017 Socket Mobile, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//
import UIKit
import SKTCapture

class MasterViewController:
    UITableViewController,
    CaptureHelperDevicePresenceDelegate,
    CaptureHelperDeviceManagerPresenceDelegate,
    CaptureHelperDeviceDecodedDataDelegate,
    CaptureHelperErrorDelegate,
    CaptureHelperDevicePowerDelegate {

    var detailViewController: DetailViewController? = nil
    var objects = NSMutableArray()

    // Capture Helper shareInstance allows to share
    // the same instance of Capture Helper with the
    // entire application. That static property can
    // be used in any views but it is recommended
    // to open only once Capture Helper (in the main
    // view controller) and pushDelegate, popDelegate
    // each time a new view requiring scanning capability
    // is loaded or unloaded respectively.
    var captureHelper = CaptureHelper.sharedInstance

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // fill out the App Info with the Bundle ID which should start by the
        // platform on which the application is running and followed with the
        // case sensitive application Bundle ID,
        // with the Socket Mobile Portal developer ID
        // and with the Application Key generated from the Socket Mobile Developer
        // portal
        let AppInfo = SKTAppInfo()
        AppInfo.appKey = "MC0CFQD1tdTpaABkppmG+iP3dB9kolYVtwIUY8c3UmEfaPoTI3AxbPOTpNgw+fo="
        AppInfo.appID = "ios:com.socketmobile.SingleEntrySwift"
        AppInfo.developerID = "bb57d8e1-f911-47ba-b510-693be162686a"
        
        // there is a stack of delegates the last push is the
        // delegate active, when a new view requiring notifications from the
        // scanner, then push its delegate and pop its delegate when the
        // view is done
        captureHelper.pushDelegate(self)
        
        // to make all the delegates able to update the UI without the app
        // having to dispatch the UI update code, set the delegateDispatchQueue
        // property to the DispatchQueue.main
        // Do the the same with the property dispatchQueue if the UI needs to 
        // be updated in any of the completion handlers
        captureHelper.delegateDispatchQueue = DispatchQueue.main

        // open Capture Helper only once in the application
        captureHelper.openWithAppInfo(AppInfo, withCompletionHandler: { (_ result: SKTResult) in
            print("Result of Capture initialization: \(result.rawValue)")
            // if you don't need host Acknowledgment, and use the
            // scanner acknowledgment, then these few lines can be
            // removed (from the #if to the #endif)
            #if HOST_ACKNOWLEDGMENT
                captureHelper.setConfirmationMode(confirmationMode: .modeApp, withCompletionHandler: { (result) in
                    print("Data Confirmation Mode returns : \(result.rawValue)")
                })
            // to remove the Host Acknowledgment if it was set before
            // put back to the default Scanner Acknowledgment also called Local Acknowledgment
            #else
                self.captureHelper.setConfirmationMode(.modeDevice, withCompletionHandler: { (result) in
                    print("Data Confirmation Mode returns : \(result.rawValue)")
                })
            #endif
        })

        // add SingleEntry item from the begining in the main list
        objects.insert("SingleEntry", at: 0);
        let indexPath=IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: AnyObject) {
        objects.insert(Date(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if let object = objects[(indexPath as NSIndexPath).row] as? NSString {
                    let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                    controller.detailItem = object
                    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                    controller.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell

        var description = "dont know"
        if let object = objects[(indexPath as NSIndexPath).row] as? NSString {
            description=object as String;
        }
        cell.textLabel?.text = description
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.removeObject(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


    // MARK: - Helper functions
    func displayBatteryLevel(_ level: UInt?, fromDevice device: CaptureHelperDevice, withResult result: SKTResult) {
        if result != SKTCaptureErrors.E_NOERROR {
            print("error while getting the device battery level: \(result.rawValue)")
        }
        else{
            let battery = SKTHelper.getCurrentLevel(fromBatteryLevel: Int(level!))
            print("the device \((device.deviceInfo.name)! as String) has a battery level: \(String(describing: battery))%")
        }
    }
    
    // MARK: - CaptureHelperDevicePresenceDelegate

    func didNotifyArrivalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("Main view device arrival:\(String(describing: device.deviceInfo.name))")
        
        // These few lines are only for the Host Acknowledgment feature,
        // if your application does not use this feature they can be removed
        // from the #if to the #endif
        #if HOST_ACKNOWLEDGMENT
            device.getDataAcknowledgmentWithCompletionHandler({(result, dataAcknowledgment) in
                if result == SKTCaptureErrors.E_NOERROR {
                    var localAck = dataAcknowledgment
                    if localAck == SKTCaptureDeviceDataAcknowledgment.on {
                        localAck = SKTCaptureDeviceDataAcknowledgment.off
                        device.setDataAcknowledgment(localAck, withCompletionHandler : {(result, propertyResult) in
                            if result != SKTCaptureErrors.E_NOERROR {
                                print("Set Local Acknowledgment returns: \(result)")
                            }
                        })
                    }
                }
            })
            
            device.getDecodeActionWithCompletionHandler(completion: {(result: SKTResult, decodeAction: SKTCaptureLocalDecodeAction?) in
                if result == SKTCaptureErrors.E_NOERROR {
                    if decodeAction != .none {
                        decodeAction = .none
                        device.setDecodeAction(decodeAction: decodeAction, withCompletionHandler:{(result: SKTResult) in
                            if result != SKTCaptureErrors.E_NOERROR {
                                print("Set Decode Action returs: \(result)")
                            }
                        })
                    }
                }
            })
        #else // to remove the Host Acknowledgment if it was set before
            device.getDataAcknowledgmentWithCompletionHandler({(result: SKTResult, dataAcknowledgment: SKTCaptureDeviceDataAcknowledgment?) in
                if result == SKTCaptureErrors.E_NOERROR {
                    if var localAck = dataAcknowledgment as SKTCaptureDeviceDataAcknowledgment! {
                        if localAck == .off {
                            localAck = .on
                            device.setDataAcknowledgment(localAck, withCompletionHandler: {(result: SKTResult) in
                                if result != SKTCaptureErrors.E_NOERROR {
                                    print("Set Data Acknowledgment returns: \(result)")
                                }
                            })
                        }
                    }
                }
            })
            
            device.getDecodeActionWithCompletionHandler({ (result: SKTResult, decodeAction: SKTCaptureLocalDecodeAction?)->Void in
                if result == SKTCaptureErrors.E_NOERROR {
                    if decodeAction == .none {
                        var action = SKTCaptureLocalDecodeAction()
                        action.insert(.beep)
                        action.insert(.flash)
                        action.insert(.rumble)
                        device.setDecodeAction(action, withCompletionHandler: { (result) in
                            if result != SKTCaptureErrors.E_NOERROR {
                                print("Set Decode Action returns: \(result)")
                            }
                            
                        })
                    }
                }
            })
        #endif
        device.getNotificationsWithCompletionHandler { (result :SKTResult, notifications:SKTCaptureNotifications?) in
            if result == SKTCaptureErrors.E_NOERROR {
                var notif = notifications!
                if !notif.contains(SKTCaptureNotifications.batteryLevelChange) {
                    print("scanner not configured for battery level change notification, doing it now...")
                    notif.insert(SKTCaptureNotifications.batteryLevelChange)
                    device.setNotifications(notif, withCompletionHandler: {(result)->Void in
                        if result != SKTCaptureErrors.E_NOERROR {
                            print("error while setting the device notifications configuration \(result)")
                        } else {
                            device.getBatteryLevelWithCompletionHandler({ (result, batteryLevel) in
                                self.displayBatteryLevel(batteryLevel, fromDevice: device, withResult: result)
                            })
                        }
                    })
                                            
                } else {
                    print("scanner already configured for battery level change notification")
                    device.getBatteryLevelWithCompletionHandler({ (result, batteryLevel)->Void in
                        self.displayBatteryLevel(batteryLevel, fromDevice: device, withResult: result)
                    })
                }
            } else {
                if result == SKTCaptureErrors.E_NOTSUPPORTED {
                    print("scanner \(String(describing: device.deviceInfo.name)) does not support reading for notifications configuration")
                } else {
                    print("scanner \(String(describing: device.deviceInfo.name)) return an error \(result) when reading for notifications configuration")
                }
            }
        }
    }

    func didNotifyRemovalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("Main view device removal:\(device.deviceInfo.name!)")
    }

    // MARK: - CaptureHelperDeviceManagerPresenceDelegate
    // THIS IS THE PLACE TO TURN ON THE BLE FEATURE SO THE D600 CAN
    // BE DISCOVERED AND CONNECT TO THIS APP
    func didNotifyArrivalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        print("device manager arrival notification")
        // this device property completion block might update UI
        // element, then we set its dispatchQueue here to this app
        // main thread
        device.dispatchQueue = DispatchQueue.main
        device.getFavoriteDevicesWithCompletionHandler { (result, favorites) in
            print("getting the favorite devices returned \(result.rawValue)")
            if result == SKTCaptureErrors.E_NOERROR {
                if let fav = favorites as String! {
                    // if favorites is empty (meaning D600 auto-discovery is off)
                    // then set it to "*" to connect to any D600 in the vicinity
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
        print("device manager removal notifcation")
    }
    // MARK: - CaptureHelperDeviceDecodedDataDelegate
    
    // This delegate is called each time a decoded data is read from the scanner
    // It has a result field that should be checked before using the decoded 
    // data. 
    // It would be set to SKTCaptureErrors.E_CANCEL if the user taps on the 
    // cancel button in the SoftScan View Finder
    func didReceiveDecodedData(_ decodedData: SKTCaptureDecodedData?, fromDevice device: CaptureHelperDevice, withResult result: SKTResult) {
        
        if result == SKTCaptureErrors.E_NOERROR {
            let rawData = decodedData?.decodedData
            let rawDataSize = rawData?.count
            print("Size: \(String(describing: rawDataSize))")
            print("data: \(String(describing: decodedData?.decodedData))")
            let string = decodedData?.stringFromDecodedData()!
            print("Decoded Data \(String(describing: string))")
            #if HOST_ACKNOWLEDGMENT
                device.setDataConfirmationWithLed(led: .green, withBeep: .good, withRumble: .good, withCompletionHandler: {(result) -> Void in
                    if result != SKTCaptureErrors.E_NOERROR {
                        print("Set Data Confirmation returns: \(result)")
                    }
                })
            #endif
        }
    }

    // MARK: - CaptureHelperErrorDelegate
    
    func didReceiveError(_ error: SKTResult) {
        print("Receive a Capture error: \(error.rawValue)")
    }

    // MARK: - CaptureHelperDevicePowerDelegate
    
    func didChangePowerState(_ powerState: SKTCapturePowerState, forDevice device: CaptureHelperDevice) {
        print("Receive a didChangePowerState \(powerState)")
    }
    
    func didChangeBatteryLevel(_ batteryLevel: Int, forDevice device: CaptureHelperDevice) {
        print("Receive a didChangeBatteryLevel \(batteryLevel)")
    }
    
}
