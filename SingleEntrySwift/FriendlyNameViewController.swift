//
//  FriendlyNameViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 10.10.25.
//  Copyright © 2025 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import UIKit
import CaptureSDK


class FriendlyNameViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var friendlyNameTextField: UITextField!

    var device: CaptureHelperDevice?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Friendly name feature"

        if let device = device {
            DispatchQueue.main.async {
                self.titleLabel?.text = device.deviceInfo.name
                self.friendlyNameTextField.text = device.deviceInfo.name
            }
        }
    }
    
    @IBAction func changeFriendlyNameAction() {
        if let text = friendlyNameTextField.text, !text.isEmpty, let device = device {
            device.setFriendlyName(text, withCompletionHandler: { result in
                print("Set Friendly Name - Result: \(result.rawValue)")
            })
        }
    }

}
