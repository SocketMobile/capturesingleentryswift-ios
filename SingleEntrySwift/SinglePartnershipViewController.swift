//
//  SinglePartnershipViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 10.10.25.
//  Copyright © 2025 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import UIKit
import CaptureSDK


class SinglePartnershipViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var statusLabel: UILabel?
    @IBOutlet var resetButton: UIButton?

    var device: CaptureHelperDevice?
    var captureHelper = CaptureHelper.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Single Partnership feature"
        self.titleLabel?.text = device?.deviceInfo.name
        self.resetButton?.isHidden = device == nil
    }
    
    @IBAction func setPermanentPartnershipWebUIAction() {
        captureHelper.setSinglePartnership(.webUI, completionHandler: { result in
            print("setPermanentPartnership through Web UI returns: \(result.rawValue)")
            DispatchQueue.main.async {
                self.statusLabel?.text = "Single Partnership WebUI returns: \(result.rawValue)"
            }
        })
    }
    
    @IBAction func setPermanentPartnershipWebUIPromptAction() {
        captureHelper.setSinglePartnership(.webUIPrompt, completionHandler: { result in
            print("setPermanentPartnership through Web UI Prompt returns: \(result.rawValue)")
            DispatchQueue.main.async {
                self.statusLabel?.text = "Single Partnership WebUIPrompt returns: \(result.rawValue)"
            }
        })
    }
    
    @IBAction func setPermanentPartnershipUuidAction() {
//        captureHelper.setSinglePartnership(.uuid, uuidString: "9d500cf3-5f06-4c12-9d50-0cf35f062c12", completionHandler: { result in
        captureHelper.setSinglePartnership(.uuid, uuidString: "4e813a59-5b31-fe79-9d50-0cf35f062c12", completionHandler: { result in
            print("setPermanentPartnership through Service UUID returns: \(result.rawValue)")
            DispatchQueue.main.async {
                self.statusLabel?.text = "Single Partnership Service UUID returns: \(result.rawValue)"
            }
        })
    }

    @IBAction func getPermanentPartnershipStatusAction() {
        captureHelper.getSinglePartnershipStatus(withCompletionHandler: { result, status in
            print("setPermanentPartnership through UUID returns: \(result.rawValue)")
            print("getSinglePartnershipStatus status returns: \(status?.rawValue ?? 0)")
            
            DispatchQueue.main.async {
                switch status {
                case .disable:
                    self.statusLabel?.text = "Single Partnership status: Disabled"
                case .webUI:
                    self.statusLabel?.text = "Single Partnership status: Web UI"
                case .webUIPrompt:
                    self.statusLabel?.text = "Single Partnership status: Web UI Prompt"
                case .uuid:
                    self.statusLabel?.text = "Single Partnership status: UUID"
                default:
                    self.statusLabel?.text = "Single Partnership status: \(result.rawValue)"
                    break
                }
            }
        })
    }
    
    @IBAction func resetPermanentPartnershipAction() {
        if let device = device {
            device.setResetSinglePartnership { result in
                print("resetPermanentPartnershipAction returns: \(result.rawValue)")
                DispatchQueue.main.async {
                    self.statusLabel?.text = ""
                }
            }
        } else {
            self.statusLabel?.text = "Single Partnership status: No device connected to reset"
        }
    }

}
