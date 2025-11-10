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

    @IBOutlet var decodedData: UITextField?
    @IBOutlet var containerView: UIView?

    // Capture Helper shareInstance allows to share
    // the same instance of Capture Helper with the
    // entire application. That static property can
    // be used in any views but it is recommended
    // to open only once Capture Helper (in the main
    // view controller) and pushDelegate, popDelegate
    // each time a new view requiring scanning capability
    // is loaded or unloaded respectively.
    var captureHelper = CaptureHelper.sharedInstance

    // An object for the purpose of this sample that aggregates all the CaptureSDK delegates
    var captureHandler: CaptureSdkHandler = CaptureSdkHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decodedData?.overrideUserInterfaceStyle = .light
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveDecodedData), name: NSNotification.Name("didReceiveDecodedDataSuccess"), object: nil)

        // fill out the App Info with the Bundle ID which should start by the
        // platform on which the application is running and followed with the
        // case sensitive application Bundle ID,
        // with the Socket Mobile Portal developer ID
        // and with the Application Key generated from the Socket Mobile Developer
        // portal https://www.socketmobile.com/developers/portal
        let AppInfo = SKTAppInfo()
        AppInfo.appKey = "MC0CFQD1tdTpaABkppmG+iP3dB9kolYVtwIUY8c3UmEfaPoTI3AxbPOTpNgw+fo="
        AppInfo.appID = "ios:com.socketmobile.SingleEntrySwift"
        AppInfo.developerID = "bb57d8e1-f911-47ba-b510-693be162686a"

        // set this CaptureHandler as the delegate of CaptureHelper (it's a very basic demo for the purpose of this sample app)
        // you can set your view controllers or others to 
        CaptureHelper.sharedInstance.pushDelegate(captureHandler)

        // to make all the delegates able to update the UI without the app
        // having to dispatch the UI update code, set the dispatchQueue
        // property to the DispatchQueue.main
        captureHelper.dispatchQueue = DispatchQueue.main

        // open Capture Helper ONLY ONCE once in the application
        // also you don't need to close it, it handles its lifecycle by itself
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
            
            CaptureHelper.sharedInstance.getVersionWithCompletionHandler { result, version in
                print("getVersionWithCompletionHandler returns : \(result.rawValue)")
                print("CaptureSDK version returns : \(version?.major ?? 0).\(version?.middle ?? 0).\(version?.minor ?? 0)")
            }
        })
    }

    @objc
    func didReceiveDecodedData(_ notification: Notification) {
        if let decodedDataString = notification.object as? String {
            DispatchQueue.main.async {
                self.decodedData?.text = decodedDataString
            }
        }
    }

}
