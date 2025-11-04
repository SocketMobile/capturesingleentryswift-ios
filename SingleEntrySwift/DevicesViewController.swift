//
//  DevicesViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 10.10.25.
//  Copyright © 2025 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import UIKit
import CaptureSDK


class DevicesViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView?
    
    var devices: [CaptureHelperDevice] = []
    var discoveredDevices: [SKTCaptureDiscoveredDeviceInfo] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""

        NotificationCenter.default.addObserver(self, selector: #selector(didNotifyArrivalForDevice), name: NSNotification.Name("didNotifyArrivalForDevice"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didNotifyRemovalForDevice), name: NSNotification.Name("didNotifyRemovalForDevice"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDiscoverDevice), name: NSNotification.Name("didDiscoverDevice"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEndDiscoveryWithResult), name: NSNotification.Name("didEndDiscoveryWithResult"), object: nil)
    }
    
    @objc
    func didNotifyArrivalForDevice(notification: NSNotification) {
        if let device: CaptureHelperDevice = notification.object as? CaptureHelperDevice {
            if !devices.contains(where: { deviceToCompare in
                return device.deviceInfo.guid == deviceToCompare.deviceInfo.guid
            }) {
                devices.append(device)
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
        }
    }
    
    @objc
    func didNotifyRemovalForDevice(notification: NSNotification) {
        if let device: CaptureHelperDevice = notification.object as? CaptureHelperDevice {
            if let index = devices.firstIndex(of: device) {
                devices.remove(at: index)
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    @objc
    func didDiscoverDevice(_ notification: Notification) {
        if let device = notification.object as? SKTCaptureDiscoveredDeviceInfo {
            if !discoveredDevices.contains(where: { deviceToCompare in
                return device.identifierUuid == deviceToCompare.identifierUuid
            }) {
                discoveredDevices.append(device)
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
        }
    }

    @objc
    func didEndDiscoveryWithResult(_ notification: Notification) {
        // If there's no discovered Bluetooth LE you can launch a Bluetooth Classic discovery for instance
        // This use the iOS native picker and the device will connect automatically to the CaptureSDK and your app
        if discoveredDevices.count == 0  {
            let alert = UIAlertController(title: "No Bluetooth Low Energy Device Found", message: "Launch a Bluetooth Classic Discovery", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

                // Then we launch a Bluetooth Classic discovery in this sample app
                // PLEASE NOTE THAT OUR DEVICES ARE MAINLY BLUETOOTH CLASSIC AND WE'RE TRANSITIONING TO BLUETOOTH LOW ENERGY DEVICES
                // THINK ABOUT DOING A BLUETOOTH CLASSIC DISCOVERY AS YOUR CUSTOMERS MAY STILL HAVE THOSE DEVICES FOR A WHILE
                // SO YOU CAN START WITH BLUETOOTH CLASSIC FIRST IF YOU WANT TO
                CaptureHelper.sharedInstance.addBluetoothDevice(.bluetoothClassic , withCompletionHandler: { result in
                    print("Add Bluetooth Classic Device result: \(result.rawValue)")
                })

            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func addDeviceAction() {
        // First we launch a Bluetooth LE discovery in this sample app
        // PLEASE NOTE THAT OUR DEVICES ARE MAINLY BLUETOOTH CLASSIC AND WE'RE TRANSITIONING TO BLUETOOTH LOW ENERGY DEVICES
        // THINK ABOUT DOING A BLUETOOTH CLASSIC DISCOVERY AS YOUR CUSTOMERS MAY STILL HAVE THOSE DEVICES FOR A WHILE
        // SO YOU CAN START WITH BLUETOOTH CLASSIC FIRST IF YOU WANT TO
        CaptureHelper.sharedInstance.addBluetoothDevice(.bluetoothLowEnergy , withCompletionHandler: { result in
            print("Add Bluetooth Low Energy Device result: \(result.rawValue)")
        })
    }

}


extension DevicesViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Connected Devices"
        case 1:
            return discoveredDevices.count > 0 ? "Discovered Devices" : ""
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return devices.count
        case 1:
            return discoveredDevices.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell: ConnectedDeviceCell = tableView.dequeueReusableCell(withIdentifier: "ConnectedDeviceCell", for: indexPath) as? ConnectedDeviceCell {
                if devices.count > 0 {
                    let device = devices[indexPath.row]
                    cell.device = device
                    cell.nameLabel.text = device.deviceInfo.name
                    cell.actionButton.isHidden = device.deviceInfo.deviceType == .socketCamC820 || device.deviceInfo.deviceType == .socketCamC860
                    cell.completion = {
                        if let index = self.devices.firstIndex(of: device) {
                            self.devices.remove(at: index)
                            DispatchQueue.main.async {
                                self.tableView?.reloadData()
                            }
                        }
                    }
                }
                return cell
            }
        case 1:
            if let cell: DiscoveredDeviceCell = tableView.dequeueReusableCell(withIdentifier: "DiscoveredDeviceCell", for: indexPath) as? DiscoveredDeviceCell {
                if discoveredDevices.count > 0 {
                    let device = discoveredDevices[indexPath.row]
                    cell.device = device
                    cell.nameLabel.text = device.name
                    cell.completion = {
                        if let index = self.discoveredDevices.firstIndex(of: device) {
                            self.discoveredDevices.remove(at: index)
                            DispatchQueue.main.async {
                                self.tableView?.reloadData()
                            }
                        }
                    }
                }
                return cell
            }
        default:
            return UITableViewCell()
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64.0
    }
}


extension DevicesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, let featuresViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeaturesViewController") as? FeaturesViewController {
            featuresViewController.device = devices[indexPath.row]
            self.navigationController?.pushViewController(featuresViewController, animated: true)
        }
    }

}


class ConnectedDeviceCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var actionButton: UIButton!
    
    var device: CaptureHelperDevice?
    var completion: (() -> Void)?
    
    @IBAction func disconnectAction() {
        if let device = self.device {
            // Removing a device is made at the CaptureHelper level like the 'addBluetoothDevice'
            CaptureHelper.sharedInstance.removeBluetoothDevice(device.deviceInfo.guid ?? "") { result in
                print("removeBluetoothDevice: \(device.deviceInfo.name ?? "") - Result: \(result.rawValue)")
                if result == .E_NOERROR, let completion = self.completion {
                    completion()
                }
            }
        }
    }
}


class DiscoveredDeviceCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var actionButton: UIButton!
    
    var device: SKTCaptureDiscoveredDeviceInfo?
    var completion: (() -> Void)?
    
    @IBAction func connectAction() {
        if let device = self.device {
            // Connecting a Bluetooth LE device happens with the Bluetooth LE device manager. Bluetooth Classic devices are connected at the iOS Settings level once discovered and selected through the iOs native picker
            CaptureHelper.sharedInstance.connectToDiscoveredDevice(device) { result in
                print("connectToDiscoveredDevice: \(device.name ?? "") - Result: \(result.rawValue)")
                if result == .E_NOERROR, let completion = self.completion {
                    completion()
                }
            }
        }
    }

}
