//
//  FeaturesViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 10.10.25.
//  Copyright © 2025 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import UIKit
import CaptureSDK

enum FeatureType: String {
    case trigger
    case friendlyName
    case symbologies
    case firmwareVersion
    case batteryLevel
    case singlePartnership
}

class FeaturesViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var tableView: UITableView?

    var device: CaptureHelperDevice?
    var features: [[FeatureType: String]] = []

    var socketCamViewController: UIViewController?
    
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
        
        self.title = "Features"
        titleLabel?.text = (device?.deviceInfo.name ?? "")
        
        features = [
            [.trigger : "Set Trigger"],
            [.friendlyName : "Get/Set Friendly Name"],
            [.symbologies : "Get/Set Symbologies"],
            [.batteryLevel : "Get Battery Level"],
        ]

        if device?.deviceInfo.deviceType != .socketCamC820 && device?.deviceInfo.deviceType != .socketCamC860 {
            features.append([.firmwareVersion : "Get Firmware Version"])
        }
    }

}

extension FeaturesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        features.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "FeatureCell", for: indexPath)

        let feature = features[indexPath.row]
        cell.textLabel?.text = feature.values.first
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64.0
    }

}

extension FeaturesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feature = features[indexPath.row]
        let key = feature.keys.first
        switch key {
        case .trigger:
            if let triggerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TriggerViewController") as? TriggerViewController {
                triggerViewController.device = device
                self.navigationController?.pushViewController(triggerViewController, animated: true)
            }
        case .friendlyName:
            if let friendlyNameViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FriendlyNameViewController") as? FriendlyNameViewController {
                friendlyNameViewController.device = device
                self.navigationController?.pushViewController(friendlyNameViewController, animated: true)
            }
        case .symbologies:
            if let symbologiesViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SymbologiesViewController") as? SymbologiesViewController {
                symbologiesViewController.device = device
                self.navigationController?.pushViewController(symbologiesViewController, animated: true)
            }
        case .batteryLevel:
            if let batteryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BatteryViewController") as? BatteryViewController {
                batteryViewController.device = device
                self.navigationController?.pushViewController(batteryViewController, animated: true)
            }
        case .firmwareVersion:
            if let firmwareViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FirmwareViewController") as? FirmwareViewController {
                firmwareViewController.device = device
                self.navigationController?.pushViewController(firmwareViewController, animated: true)
            }
        default:
            break
        }
    }
    
}
