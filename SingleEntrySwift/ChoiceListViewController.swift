//
//  ChoiceListViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 2.2.23.
//  Copyright © 2023 Socket Mobile, Inc. All rights reserved.
//

import CaptureSDK
import UIKit


class ChoiceListViewController: UIViewController {
  
    @IBOutlet var tableView: UITableView?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        updateList()
    }

    public func updateList() {
        tableView?.reloadData()
    }
}

extension ChoiceListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SingleEntry.shared.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let key = SingleEntry.shared.items[indexPath.row]
        
        var title = ""
        switch key {
            case .settings:
                title = "Settings"
            case .socketCam:
                title = "SocketCam"
            case .deviceThemes:
                title = "Device - Themes selection"
            case .deviceTrigger:
                title = "Device - Trigger"
            case .devicePower:
                title = "Device - Power"
        }

        cell.textLabel?.text = title

        return cell
    }

}

extension ChoiceListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = SingleEntry.shared.items[indexPath.row]
        
        var viewControllerName = ""
        switch key {
            case .settings:
                viewControllerName = "SettingsViewController"
            case .socketCam:
                viewControllerName = "SocketCamViewController"
            case .deviceThemes:
                viewControllerName = "DeviceThemesViewController"
            case .deviceTrigger:
                viewControllerName = "DeviceTriggerViewController"
            case .devicePower:
                viewControllerName = "DevicePowerViewController"
        }

        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewControllerName)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
