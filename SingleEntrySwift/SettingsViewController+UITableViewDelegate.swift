//
//  SettingsViewController+UITableViewDelegate.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 02.08.22.
//  Copyright © 2022 Socket Mobile, Inc. All rights reserved.
//

import CaptureSDK
import UIKit

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = tableView.cellForRow(at: indexPath) {

            let dataSource: SKTCaptureDataSource = symbologies[indexPath.row]
            
            if dataSource.status == .enable {
                dataSource.status = .disable
            } else if dataSource.status == .disable {
                dataSource.status = .enable
            }
            
            let devices = CaptureHelper.sharedInstance.getDevices()
            for device in devices {
                if device.deviceInfo.name == "SocketCam C820" {
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
