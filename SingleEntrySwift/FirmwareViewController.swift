//
//  FirmwareViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 10.10.25.
//  Copyright © 2025 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import UIKit
import CaptureSDK


class FirmwareViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var firmwareLabel: UILabel?

    var device: CaptureHelperDevice?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Firmware Version feature"
        self.titleLabel?.text = device?.deviceInfo.name
    }
    
    @IBAction func firmwareVersionAction() {
        if let device = device {
            device.getFirmwareVersionWithCompletionHandler({ result, version in
                print("Get Firmware Version Result: \(result.rawValue)")

                if let version = version {
                    DispatchQueue.main.async {
                        self.firmwareLabel?.text = "Firmware Version: \(version.major).\(version.middle).\(version.minor)\nFirmware Date: \(version.month).\(version.day).\(version.year)"
                    }
                }
            })
        }
    }

}
