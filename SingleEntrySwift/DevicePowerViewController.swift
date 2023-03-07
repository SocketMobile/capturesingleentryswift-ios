//
//  DevicePowerViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 2.2.23.
//  Copyright © 2023 Socket Mobile, Inc. All rights reserved.
//

import UIKit
import CaptureSDK

class DevicePowerViewController: UIViewController {

    @IBOutlet var statusLabel: UILabel?
    @IBOutlet var powerStateLabel: UILabel?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.statusLabel?.text = ""

        self.powerStateLabel?.text = "Power state: "

        SingleEntry.shared.nfcDevice?.getBatteryLevelWithCompletionHandler { result, batteryLevel in
            DispatchQueue.main.async {
                let arrayOfBytes = withUnsafeBytes(of: batteryLevel?.littleEndian, Array.init)
                print("Receive a didChangeBatteryLevel \(String(describing: batteryLevel)) => Current value: \(arrayOfBytes[1])%")

                let battery = "Status: Battery: \(arrayOfBytes[1])%"
                self.statusLabel?.text = battery
            }
        }
    }

    func updateBattery(_ battery: Int) {
        let arrayOfBytes = withUnsafeBytes(of: battery.littleEndian, Array.init)
        print("Receive a didChangeBatteryLevel \(String(describing: battery)) => Current value: \(arrayOfBytes[1])%")
        let batteryLevel = "Status: Battery: \(arrayOfBytes[1])%"
        self.statusLabel?.text = batteryLevel
    }

    func updatePowerState(_ powerState: SKTCapturePowerState) {
        switch powerState {
            case .onAc:
                self.powerStateLabel?.text = "Power state: on AC"
            case .onBattery:
                self.powerStateLabel?.text = "Power state: on battery"
            case .onCradle:
                self.powerStateLabel?.text = "Power state: on cradle"
            case .unknown:
                self.powerStateLabel?.text = "Power state: unknown"
            @unknown default:
                break
        }
    }

}
