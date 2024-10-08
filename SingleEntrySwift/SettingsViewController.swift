//
//  SettingsViewController.swift
//  SingleEntrySwift
//
//  Created by Eric Glaenzer on 10/27/15.
//  Copyright © 2015 Socket Mobile, Inc. All rights reserved.
//

import UIKit
import CaptureSDK

class SettingsViewController: UIViewController, CaptureHelperDevicePresenceDelegate, CaptureHelperDeviceManagerPresenceDelegate{
    var deviceManager: CaptureHelperDeviceManager?
    var symbologies: [SKTCaptureDataSource] = []

    @IBOutlet var socketCamSwitch: UISwitch!
    @IBOutlet var captureVersion: UILabel!
    @IBOutlet var setFavoritesSwitch: UISwitch!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var appVersion: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // retrieve the current status of SocketCam
        let capture = CaptureHelper.sharedInstance

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
        
        // check the NFC support
        if let dm = deviceManager {
            dm.getFavoriteDevicesWithCompletionHandler({ (result, favorites) in
                print("getting the Device Manager favorites returns \(result.rawValue)")
                if result == SKTCaptureErrors.E_NOERROR {
                    if let fav = favorites {
                        self.setFavoritesSwitch.isOn = !fav.isEmpty
                    }
                }
            })
        }
 
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            appVersion.text = "App Version: \(version).\(build)"
        }
     }

    override func viewDidAppear(_ animated: Bool) {
        CaptureHelper.sharedInstance.pushDelegate(self)
        let devices = CaptureHelper.sharedInstance.getDevices()
        for device in devices {
            if device.deviceInfo.deviceType == .socketCamC820 || device.deviceInfo.deviceType == .socketCamC860 {
                // Get symbologies for SocketCam
                for i in 0...SKTCaptureDataSourceID.lastSymbologyID.rawValue {
                    device.getDataSourceInfoFromId(SKTCaptureDataSourceID(rawValue: i) ?? SKTCaptureDataSourceID.notSpecified) { [weak self] result, dataSourceInfo in
                        guard let self = self else { return }
                        print("----> Data source ID: \(String(describing: dataSourceInfo?.id)) - Name: \(String(describing: dataSourceInfo?.name)) - Enabled: \(String(describing: dataSourceInfo?.status.rawValue))")

                        if let dataSource = dataSourceInfo, dataSource.status != .notSupported {
                            self.symbologies.append(dataSource)
                            DispatchQueue.main.async {
                                self.tableView?.reloadData()
                            }
                        }
                    }
                }
                break
            } else {
                // Get symbologies for other devices
                for i in 0...SKTCaptureDataSourceID.lastSymbologyID.rawValue {
                    device.getDataSourceInfoFromId(SKTCaptureDataSourceID(rawValue: i) ?? SKTCaptureDataSourceID.notSpecified) { [weak self] result, dataSourceInfo in
                        guard let self = self else { return }
                        print("----> Data source ID: \(dataSourceInfo?.id.rawValue ?? 0) - Name: \(dataSourceInfo?.name ?? "")) - Enabled: \(dataSourceInfo?.status.rawValue ?? 0)")

                        if let dataSource = dataSourceInfo, dataSource.status != .notSupported {
                            self.symbologies.append(dataSource)
                            DispatchQueue.main.async {
                                self.tableView?.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        CaptureHelper.sharedInstance.popDelegate(self)
    }

    @IBAction func changeNFCSupport(_ sender: UISwitch) {
        let deviceManagers = CaptureHelper.sharedInstance.getDeviceManagers()
        for d in deviceManagers {
            deviceManager = d
        }
        if let dm = deviceManager {
            if setFavoritesSwitch.isOn {
                // In order to connect to 1 Bluetooth Low Energy device you need to put 1`*`. For 2 devices: "*,*". 3 devices: "*,*,*", etc...
                dm.setFavoriteDevices("*", withCompletionHandler: { (result) in
                    print("turning ON connection to Bluetooth Low Energy devices returns \(result.rawValue)")
                })
            } else {
                print("turn off the NFC support...")
                dm.setFavoriteDevices("", withCompletionHandler: { (result) in
                    print("turning OFF connection to Bluetooth Low Energy devices returns \(result.rawValue)")
                })
            }
        } else {
            setFavoritesSwitch.isEnabled = false
        }
    }

    
    // MARK: - CaptureHelper Delegates
    /**
    * called each time a device connects to the host
    * @param result contains the result of the connection
    * @param newDevice contains the device information
    */
    func didNotifyArrivalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("Settings: Device Arrival")
    }
    
    /**
    * called each time a device disconnect from the host
    * @param deviceRemoved contains the device information
    */
    func didNotifyRemovalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("Settings: Device Removal")
    }
    
    func didNotifyArrivalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        print("Settings: Device Manager Arrival")
        deviceManager = device
        deviceManager?.getFavoriteDevicesWithCompletionHandler({ (result, favorites) in
            if result == SKTCaptureErrors.E_NOERROR {
                self.setFavoritesSwitch.isOn = !favorites!.isEmpty
            }
        })
    }
    
    func didNotifyRemovalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        print("Settings: Device Manager Removal")
        deviceManager = nil
    }
}

extension SettingsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        symbologies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "tt", for: indexPath)

        cell.accessoryType = symbologies[indexPath.row].status == .enable ? .checkmark : .none
        cell.textLabel?.text = symbologies[indexPath.row].name
        cell.selectionStyle = .none

        return cell
    }

}

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _: UITableViewCell = tableView.cellForRow(at: indexPath) {

            let dataSource: SKTCaptureDataSource = symbologies[indexPath.row]

            if dataSource.status == .enable {
                dataSource.status = .disable
            } else if dataSource.status == .disable {
                dataSource.status = .enable
            }

            let devices = CaptureHelper.sharedInstance.getDevices()
            for device in devices {
                if device.deviceInfo.deviceType == .socketCamC820 || device.deviceInfo.deviceType == .socketCamC860 {
                    device.setDataSourceInfo(dataSource) { [weak self] result in
                        if result == .E_NOERROR {
                            guard let self = self else { return }

                            DispatchQueue.main.async {
                                self.tableView?.reloadData()
                            }
                        }
                    }
                } else {
                    device.setDataSourceInfo(dataSource) { [weak self] result in
                        if result == .E_NOERROR {
                            guard let self = self else { return }

                            DispatchQueue.main.async {
                                self.tableView?.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }

}
