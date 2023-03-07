//
//  DeviceTriggerViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 2.2.23.
//  Copyright © 2023 Socket Mobile, Inc. All rights reserved.
//

import UIKit
import CaptureSDK

class DeviceTriggerViewController: UIViewController {

    @IBOutlet var tableView: UITableView?

    var items: [String] = [
        "Start Trigger NFC Continous",
        "Start Trigger NFC until read",
        "Stop Trigger NFC",
    ]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false

        updateUI()
    }

    func updateUI() {
        if SingleEntry.shared.nfcDevice?.deviceInfo.deviceType == .NFCS370 {
            items.append("Start Trigger Barcode Continous")
            items.append("Start Trigger Barcode until read")
            items.append("Stop Trigger Barcode")
        }
        
        tableView?.reloadData()
    }

    @IBAction func triggerNfcStartUntilReadAction() {
        SingleEntry.shared.nfcDevice?.setTrigger(.continuousScanUntilRead, withCompletionHandler: { result in
            print("---> NFC trigger start until read: \(result.rawValue)")
            self.displayAlertForResult(result, forOperation: "triggerNfcStartUntilReadAction")
        })
    }

    @IBAction func triggerBarcodeStartUntilReadAction() {
        SingleEntry.shared.barcodeDevice?.setTrigger(.continuousScanUntilRead, withCompletionHandler: { result in
            print("---> Baarcode trigger start until read: \(result.rawValue)")
            self.displayAlertForResult(result, forOperation: "triggerBarcodeStartUntilReadAction")
        })
    }

    @IBAction func triggerNfcStartContinuousAction() {
        SingleEntry.shared.nfcDevice?.setTrigger(.continuousScan, withCompletionHandler: { result in
            print("---> NFC trigger start continuous: \(result.rawValue)")
            self.displayAlertForResult(result, forOperation: "triggerNfcStartContinuousAction")
        })
    }

    @IBAction func triggerBarcodeStartContinuousAction() {
        SingleEntry.shared.barcodeDevice?.setTrigger(.continuousScan, withCompletionHandler: { result in
            print("---> Baarcode trigger start continuous: \(result.rawValue)")
            self.displayAlertForResult(result, forOperation: "triggerBarcodeStartContinuousAction")
        })
    }

    @IBAction func triggerNfcStopAction() {
        SingleEntry.shared.nfcDevice?.setTrigger(.stop, withCompletionHandler: { result in
            print("---> NFC trigger stop: \(result.rawValue)")
            self.displayAlertForResult(result, forOperation: "triggerNfcStopAction")
        })
    }

    @IBAction func triggerBarcodeStopAction() {
        SingleEntry.shared.barcodeDevice?.setTrigger(.stop, withCompletionHandler: { result in
            print("---> Baarcode trigger stop: \(result.rawValue)")
            self.displayAlertForResult(result, forOperation: "triggerBarcodeStopAction")
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

extension DeviceTriggerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let item = items[indexPath.row]
        cell.textLabel?.text = item
        
        return cell
    }
    
}

extension DeviceTriggerViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 0:
                triggerNfcStartContinuousAction()
                break
            case 1:
                triggerNfcStartUntilReadAction()
                break
            case 2:
                triggerNfcStopAction()
                break
            case 3:
                triggerBarcodeStartContinuousAction()
                break
            case 4:
                triggerBarcodeStartUntilReadAction()
                break
            case 5:
                triggerBarcodeStopAction()
                break
            default:
                break
        }
    }

}
