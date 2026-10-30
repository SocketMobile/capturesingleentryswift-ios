//
//  PcscViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 14.10.26.
//  Copyright © 2026 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import UIKit
import CaptureSDK



class PcscViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var statusLabel: UILabel?
    @IBOutlet var switchToCouplerButton: UIButton?
    @IBOutlet var switchToReaderButton: UIButton?

    var device: CaptureHelperDevice?


    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "PCSC feature"
        self.titleLabel?.text = device?.deviceInfo.name
    }

    @IBAction func switchToCouplerAction() {
        if let device = device {
            device.switchDeviceToCoupler({ result in
                print("Switch to Coupler mode - Result: \(result.rawValue)")
                DispatchQueue.main.async {
                    self.statusLabel?.text = "Switch to Coupler mode result: \(result.rawValue)"
                }
            })
        }
    }

    @IBAction func switchToReaderAction() {
        if let device = device {
            device.switchDeviceToReader({ result in
                print("Switch to Reader mode - Result: \(result.rawValue)")
                DispatchQueue.main.async {
                    self.statusLabel?.text = "Switch to Reader mode result: \(result.rawValue)"
                }
            })
        }
    }

}
