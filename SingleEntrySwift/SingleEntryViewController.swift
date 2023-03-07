//
//  SingleEntryViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 24.03.22.
//  Copyright © 2022 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import CaptureSDK
import UIKit


class SingleEntryViewController: UIViewController {
    
    @IBOutlet var connectionStatus: UILabel?
    @IBOutlet var decodedData: UITextField?
    @IBOutlet var containerView: UIView?
    
    let socketCamBind = SocketCamBind() // for SwiftUI sample
    var showSocketCamSwiftUI = false
    var choiceViewController: ChoiceListViewController?
    var choiceNavigationViewController: UINavigationController?
    var devicePowerViewController: DevicePowerViewController?

    var captureHelper = CaptureHelper.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

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
            captureHelper.pushDelegate(SingleEntry.shared)
            
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
                self.captureHelper.setConfirmationMode(confirmationMode: .modeApp, withCompletionHandler: { (result) in
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
        
        SingleEntry.shared.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            
        CaptureHelper.sharedInstance.pushDelegate(SingleEntry.shared)
        displayScanners()
        
        decodedData?.resignFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        SingleEntry.shared.scanners = []
        CaptureHelper.sharedInstance.popDelegate(SingleEntry.shared)
        
        decodedData?.resignFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChoiceViewController" {
            choiceNavigationViewController = segue.destination as? UINavigationController
            if let choiceViewController = choiceNavigationViewController?.viewControllers.first as? ChoiceListViewController {
                self.choiceViewController = choiceViewController
            }
        }
    }

    // MARK: - Utility functions

    func displayScanners() {
        if let status = connectionStatus {
            // the main dispatch queue is required to update the UI or the delegateDispatchQueue CaptureHelper property can be set instead
            DispatchQueue.main.async() {
                status.text = ""
                if SingleEntry.shared.scanners.count == 0 {
                    status.text = SingleEntry.shared.noScannerConnected
                } else if status.text != "" {
                    status.text?.removeLast()
                }
                for scanner in SingleEntry.shared.scanners {
                    status.text = status.text! + (scanner as String) + "\n"
                }
            }
        }
    }

    func displayAlertForResult(_ result: SKTResult, forOperation operation: String) {
        if result != .E_NOERROR {
            let errorTxt = "Error \(result.rawValue) while doing a \(operation)"
            let alert = UIAlertController(title: "Capture Error", message: errorTxt, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

extension SingleEntryViewController: SingleEntryDelegate {
    
    func notifyDevicePresence() {
        displayScanners()
        choiceViewController?.updateList()
    }
    
    func notifyDeviceManagerPresence() {
        displayScanners()
        choiceViewController?.updateList()
    }
    
    func notifyDecodedDataString(dataString: String) {
        decodedData?.text = dataString
        socketCamBind.decodedtring = dataString
    }
       
    func notifyPowerState(_ powerState: SKTCapturePowerState) {
        if choiceNavigationViewController?.viewControllers.last is DevicePowerViewController {
            devicePowerViewController = choiceNavigationViewController?.viewControllers.last as? DevicePowerViewController
            devicePowerViewController?.updatePowerState(powerState)
        }
    }
    
    func notifyBatteryLevel(_ batteryLevel: Int) {
        if choiceNavigationViewController?.viewControllers.last is DevicePowerViewController {
            devicePowerViewController = choiceNavigationViewController?.viewControllers.last as? DevicePowerViewController
            devicePowerViewController?.updateBattery(batteryLevel)
        }
    }
    
    func notifyError(_ error: SKTResult) {}

}
