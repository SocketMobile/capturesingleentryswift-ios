//
//  SettingsViewController.swift
//  SingleEntrySwift
//
//  Created by Eric Glaenzer on 10/27/15.
//  Copyright © 2015 Socket Mobile, Inc. All rights reserved.
//

import UIKit
import CaptureSDK


class SettingsViewController: UIViewController {
    
    @IBOutlet var captureVersion: UILabel!
    @IBOutlet var appVersion: UILabel!

    var symbologies: [SKTCaptureDataSource] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // ask for the Capture version
        CaptureHelper.sharedInstance.getVersionWithCompletionHandler({ (result, version) in
            print("getCaptureVersion completion received! - Result:", result.rawValue)
            if result == SKTCaptureErrors.E_NOERROR {
                let major = String(format:"%d",(version?.major)!)
                let middle = String(format:"%d",(version?.middle)!)
                let minor = String(format:"%d",(version?.minor)!)
                let build = String(format:"%d",(version?.build)!)
                print("receive Capture version: \(major).\(middle).\(minor).\(build)")
                self.captureVersion.text = "Capture Version: \(major).\(middle).\(minor).\(build)"
            }
        })
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            appVersion.text = "App Version: \(version).\(build)"
        }
     }

}
