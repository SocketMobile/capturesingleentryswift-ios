//
//  SymbologiesViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 10.10.25.
//  Copyright © 2025 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import UIKit
import CaptureSDK


class SymbologiesViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var tableView: UITableView?
    
    var device: CaptureHelperDevice?
    var symbologies: [SKTCaptureDataSource] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Symbologies features"
        self.titleLabel?.text = device?.deviceInfo.name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let device = device {
            // Build the list of all the symbologies except the ones not supported by the device
            if device.isBarcodeReader {
                for i in 0...SKTCaptureDataSourceID.lastSymbologyID.rawValue {
                    device.getDataSourceInfoFromId(SKTCaptureDataSourceID(rawValue: i) ?? SKTCaptureDataSourceID.notSpecified) { [weak self] result, dataSourceInfo in
                        guard let self = self else { return }
                        
                        print("getDataSourceInfoFromId: \(String(describing: dataSourceInfo?.id.rawValue ?? 0)) - Name: \(dataSourceInfo?.name ?? "") - Enabled: \(dataSourceInfo?.status.rawValue ?? 0)")
                        
                        if let dataSource = dataSourceInfo, dataSource.status != .notSupported {
                            self.symbologies.append(dataSource)
                            DispatchQueue.main.async {
                                self.tableView?.reloadData()
                            }
                        }
                    }
                }
            }
            if device.isNFCReader {
                for i in SKTCaptureDataSourceID.tagTypeISO14443TypeA.rawValue...SKTCaptureDataSourceID.tagTypeLastTagType.rawValue {
                    device.getDataSourceInfoFromId(SKTCaptureDataSourceID(rawValue: i) ?? SKTCaptureDataSourceID.notSpecified) { [weak self] result, dataSourceInfo in
                        guard let self = self else { return }

                        print("getDataSourceInfoFromId: \(String(describing: dataSourceInfo?.id.rawValue ?? 0)) - Name: \(dataSourceInfo?.name ?? "") - Enabled: \(dataSourceInfo?.status.rawValue ?? 0)")

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
    
}


extension SymbologiesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        symbologies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "tt", for: indexPath)

        let symbology: SKTCaptureDataSource = symbologies[indexPath.row]
        cell.textLabel?.text = symbology.name
        cell.accessoryType = symbology.status == .enable ? .checkmark : .none

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64.0
    }
}


extension SymbologiesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _: UITableViewCell = tableView.cellForRow(at: indexPath) {
            let dataSource: SKTCaptureDataSource = symbologies[indexPath.row]

            if dataSource.status == .enable {
                dataSource.status = .disable
            } else if dataSource.status == .disable {
                dataSource.status = .enable
            }
            
            if let device = device {
                device.setDataSourceInfo(dataSource) { [weak self] result in
                    print("setDataSourceInfo - \(dataSource.name ?? ""): \(result.rawValue)")
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
