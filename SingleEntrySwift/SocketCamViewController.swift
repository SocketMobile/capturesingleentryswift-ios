//
//  SocketCamViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 2.2.23.
//  Copyright © 2023 Socket Mobile, Inc. All rights reserved.
//

import UIKit
import CaptureSDK

class SocketCamViewController: UIViewController {

    @IBOutlet var socketCamTrigger: UIButton!
    @IBOutlet var socketCamTriggerContinuous: UIButton!

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }

    @IBAction func socketCamAction() {
        if let scanner = SingleEntry.shared.socketCam as CaptureHelperDevice? {
            scanner.setTrigger(.start, withCompletionHandler: {(result) in
                print("triggering the device returns: \(result.rawValue)")
            })
        }
    }

    @IBAction func socketCamContinousAction() {
        if let scanner = SingleEntry.shared.socketCam as CaptureHelperDevice? {
            scanner.setTrigger(.continuousScan, withCompletionHandler: {(result) in
                print("triggering the device returns: \(result.rawValue)")
                if result != .E_NOERROR {

                }
            })
        }
    }

}
