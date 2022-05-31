//
//  SingleEntry.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 24.03.22.
//  Copyright © 2022 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import UIKit
import CaptureSDK

class SingleEntryViewController: UIViewController {
  
    @IBOutlet var connectionStatus: UILabel?
    @IBOutlet var statusLabel: UILabel?
    @IBOutlet var decodedData: UITextField?
    @IBOutlet var socketCamTrigger: UIButton?
    @IBOutlet var socketCamContinuousScan: UIButton?

    let noScannerConnected = "No scanner connected"
    var scanners : [String] = []  // keep a list of scanners to display in the status
    var socketCam : CaptureHelperDevice?  // keep a reference on the SocketCam Scanner
    var lastDeviceConnected : CaptureHelperDevice?
    var detailItem: AnyObject?
    var showSocketCamOverlay = false
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
        
        socketCamTrigger?.isHidden = true
        socketCamContinuousScan?.isHidden = true
        if #available(iOS 13, *) {
            decodedData?.overrideUserInterfaceStyle = .light
        }

        // there is a stack of delegates the last push is the
        // delegate active, when a new view requiring notifications from the
        // scanner, then push its delegate and pop its delegate when the
        // view is done
        captureHelper.pushDelegate(self)
        
        // to make all the delegates able to update the UI without the app
        // having to dispatch the UI update code, set the dispatchQueue
        // property to the DispatchQueue.main
        captureHelper.dispatchQueue = DispatchQueue.main

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

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // if we are showing the SocketCam Overlay view we don't
        // want to push our delegate again when our view becomes active
        if showSocketCamOverlay == false {
            // since we use CaptureHelper in shared mode, we push this
            // view controller delegate to the CaptureHelper delegates stack
            CaptureHelper.sharedInstance.pushDelegate(self)
        }
        showSocketCamOverlay = false
        displayScanners()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // if we are showing the SocketCam Overlay view we don't
        // want to remove our delegate from the CaptureHelper delegates stack
        if showSocketCamOverlay == false {
            // remove all the scanner names from the list
            // because in CaptureHelper shared mode we will receive again
            // the deviceArrival for each connected scanner once this view
            // becomes active again
            scanners = []
            socketCamTrigger?.isHidden = true
            socketCamContinuousScan?.isHidden = true
            CaptureHelper.sharedInstance.popDelegate(self)
        }
    }

    @IBAction func socketCamAction(_ sender: AnyObject) {
        if let scanner = socketCam as CaptureHelperDevice? {
            showSocketCamOverlay = true
            scanner.setTrigger(.start, withCompletionHandler: {(result) in
                self.displayAlertForResult(result, forOperation: "SetTrigger")
                if result != .E_NOERROR {
                    self.showSocketCamOverlay = false
                }
            })
        }
        else if let device = lastDeviceConnected {
            device.setTrigger(.start, withCompletionHandler: { (result) in
                print("triggering the device returns: \(result.rawValue)")
            })
        }
    }

    @IBAction func socketCamContinousScanAction(_ sender: AnyObject) {
        if let scanner = socketCam as CaptureHelperDevice? {
            showSocketCamOverlay = true
            scanner.setTrigger(.continuousScan, withCompletionHandler: {(result) in
                self.displayAlertForResult(result, forOperation: "SetTrigger")
                if result != .E_NOERROR {
                    self.showSocketCamOverlay = false
                }
            })
        }
        else if let device = lastDeviceConnected {
            device.setTrigger(.continuousScan, withCompletionHandler: { (result) in
                print("triggering the device returns: \(result.rawValue)")
            })
        }
    }

    // MARK: - Utility functions

    func displayScanners(){
        if let status = connectionStatus {
            // the main dispatch queue is required to update the UI
            // or the delegateDispatchQueue CaptureHelper property
            // can be set instead
//            DispatchQueue.main.async() {
                status.text = ""
                for scanner in self.scanners {
                    status.text = status.text! + (scanner as String) + "\n"
                }
                if(self.scanners.count == 0){
                    status.text = self.noScannerConnected
                }
//            }
        }
    }

    func displayAlertForResult(_ result: SKTResult, forOperation operation: String){
        if result != .E_NOERROR {
            let errorTxt = "Error \(result.rawValue) while doing a \(operation)"
            let alert = UIAlertController(title: "Capture Error", message: errorTxt, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Helper functions

    func displayBatteryLevel(_ level: UInt?, fromDevice device: CaptureHelperDevice, withResult result: SKTResult) {
        if result != .E_NOERROR {
            print("error while getting the device battery level: \(result.rawValue)")
        }
        else{
            let battery = SKTHelper.getCurrentLevel(fromBatteryLevel: Int(level!))
            print("the device \((device.deviceInfo.name)! as String) has a battery level: \(String(describing: battery))%")
        }
    }

}
