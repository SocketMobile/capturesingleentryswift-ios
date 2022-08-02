//
//  SettingsViewController+UITableViewDataSource.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 02.08.22.
//  Copyright © 2022 Socket Mobile, Inc. All rights reserved.
//

import CaptureSDK
import UIKit

extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.symbologies.count > 0 ? self.symbologies.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = .white
        cell.backgroundColor = .white
        cell.accessoryType = symbologies[indexPath.row].status == .enable ? .checkmark : .none
        cell.textLabel?.text = symbologies[indexPath.row].name
        cell.textLabel?.textColor = .black
        cell.selectionStyle = .none

        return cell
    }
    
}
