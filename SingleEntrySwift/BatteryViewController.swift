//
//  BatteryViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 10.10.25.
//  Copyright © 2025 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import UIKit
import CaptureSDK


class BatteryViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var batteryLabel: UILabel?

    var device: CaptureHelperDevice?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Battery feature"
        self.titleLabel?.text = device?.deviceInfo.name
    }
    
    @IBAction func batteryLevelAction() {
        if let device = device {
            device.getBatteryLevelWithCompletionHandler({ result, batteryLevel in
                print("Get Battery Level: \(batteryLevel ?? 0) - Result: \(result.rawValue)")

                let finalBatteryLevel = SKTHelper.getCurrentLevel(fromBatteryLevel: Int(batteryLevel ?? 00))
                DispatchQueue.main.async {
                    self.batteryLabel?.text = "Battery level: \(finalBatteryLevel)%"
                }
            })
        }
    }

    @IBAction func powerStateAction() {
        if let device = device {
            device.getPowerStateWithCompletionHandler({ result, powerState in
                print("Get Power State: \(powerState ?? 0) - Result: \(result.rawValue)")

                let finalPowerState = SKTHelper.getPowerState(fromPower: Int(powerState ?? 0))
                DispatchQueue.main.async {
                    self.batteryLabel?.text = "Power state: \(finalPowerState)"
                }
            })
        }
    }

}
