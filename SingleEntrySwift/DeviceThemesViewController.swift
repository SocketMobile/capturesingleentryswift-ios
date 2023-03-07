//
//  DeviceThemesViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 2.2.23.
//  Copyright © 2023 Socket Mobile, Inc. All rights reserved.
//

import UIKit
import CaptureSDK

class DeviceThemesViewController: UIViewController {

    @IBOutlet var commonSegmentedControl: UISegmentedControl!
    @IBOutlet var nfcSegmentedControl: UISegmentedControl!
    @IBOutlet var barcodeLabel: UILabel!
    @IBOutlet var barcodeSegmentedControl: UISegmentedControl!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false

        getThemesAction()
        
        barcodeSegmentedControl.isHidden = SingleEntry.shared.barcodeDevice == nil
        barcodeLabel.isHidden = SingleEntry.shared.barcodeDevice == nil
    }

    @IBAction func selectThemeCommonAction(sender: UISegmentedControl) {
        var theme: SKTCaptureThemeSelection = SKTCaptureThemeSelection.health
        switch sender.selectedSegmentIndex {
            case 0:
                theme = SKTCaptureThemeSelection.health
                break
            case 1:
                theme = SKTCaptureThemeSelection.access
                break
            case 2:
                theme = SKTCaptureThemeSelection.value
                break
            case 3:
                theme = SKTCaptureThemeSelection.membership
                break
            default:
                break
        }

        SingleEntry.shared.nfcDevice?.setThemeSelection(SKTCaptureThemeSelectionMask.default, themes: [theme, .none, .none], withCompletionHandler: { result in
            print("---> NFC set theme to \(theme) result: \(result.rawValue)")
            self.displayAlertForResult(result, forOperation: "selectThemeCommonAction")
        })
    }

    @IBAction func selectThemeNfcAction(sender: UISegmentedControl) {
        var theme: SKTCaptureThemeSelection = SKTCaptureThemeSelection.health
        switch sender.selectedSegmentIndex {
            case 0:
                theme = SKTCaptureThemeSelection.health
                break
            case 1:
                theme = SKTCaptureThemeSelection.access
                break
            case 2:
                theme = SKTCaptureThemeSelection.value
                break
            case 3:
                theme = SKTCaptureThemeSelection.membership
                break
            default:
                break
        }

        SingleEntry.shared.nfcDevice?.setThemeSelection(SKTCaptureThemeSelectionMask.nfc, themes: [.none, theme, .none], withCompletionHandler: { result in
            print("---> NFC set theme to \(theme) result: \(result.rawValue)")
            self.displayAlertForResult(result, forOperation: "selectThemeNfcAction")
        })
    }

    @IBAction func selectThemeBarcodeAction(sender: UISegmentedControl) {
        var theme: SKTCaptureThemeSelection = SKTCaptureThemeSelection.health
        switch sender.selectedSegmentIndex {
            case 0:
                theme = SKTCaptureThemeSelection.health
                break
            case 1:
                theme = SKTCaptureThemeSelection.access
                break
            case 2:
                theme = SKTCaptureThemeSelection.value
                break
            case 3:
                theme = SKTCaptureThemeSelection.membership
                break
            default:
                break
        }

        SingleEntry.shared.barcodeDevice?.setThemeSelection(SKTCaptureThemeSelectionMask.nfcBarcode, themes: [.none, .none, theme], withCompletionHandler: { result in
            print("---> Barcode set theme to \(theme) result: \(result.rawValue)")
            self.displayAlertForResult(result, forOperation: "selectThemeBarcodeAction")
        })
    }

    @IBAction func getThemesAction() {
        SingleEntry.shared.nfcDevice?.getThemeSelection(with: { result, commandResult in
            print("---> Get themes result: \(result.rawValue)")
            
            self.displayAlertForResult(result, forOperation: "getThemesAction")

            if result == .E_NOERROR {
                if commandResult?.count == 8 {
                    if commandResult?[4] == 0x00 {
                        DispatchQueue.main.async {
                            let commonTheme = commandResult?[5]
                            let nfcTheme = commandResult?[6]
                            let barcodeTheme = commandResult?[7]
                            
                            self.commonSegmentedControl?.selectedSegmentIndex = Int(commonTheme ?? UInt8()) - 1
                            self.nfcSegmentedControl?.selectedSegmentIndex = Int(nfcTheme ?? UInt8()) - 1
                            self.barcodeSegmentedControl?.selectedSegmentIndex = Int(barcodeTheme ?? UInt8()) - 1
                        }
                    }
                }
            }
        })
    }

    func displayAlertForResult(_ result: SKTResult, forOperation operation: String){
        if result != .E_NOERROR {
            let errorTxt = "Error \(result.rawValue) while doing a \(operation)"
            let alert = UIAlertController(title: "Capture Error", message: errorTxt, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}
