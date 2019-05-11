//
//  DetailViewController.swift
//  SingleEntrySwift
//
//  Created by Eric Glaenzer on 11/17/14.
// Copyright 2015 Socket Mobile, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import SKTCapture

class DetailViewController: UIViewController, CaptureHelperDevicePresenceDelegate,CaptureHelperDeviceDecodedDataDelegate {
    let noScannerConnected = "No scanner connected"
    var scanners : [String] = []  // keep a list of scanners to display in the status
    var softScanner : CaptureHelperDevice?  // keep a reference on the SoftScan Scanner
    var lastDeviceConnected : CaptureHelperDevice?
    var captureHelper = CaptureHelper.sharedInstance
    @IBOutlet weak var connectionStatus: UILabel!
    @IBOutlet weak var decodedData: UITextField!
    @IBOutlet weak var softScanTrigger: UIButton!

    var detailItem: AnyObject?
    var showSoftScanOverlay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        softScanTrigger.isHidden = true;

    }
    
    override func viewDidAppear(_ animated: Bool) {
        // if we are showing the SoftScan Overlay view we don't
        // want to push our delegate again when our view becomes active
        if showSoftScanOverlay == false {
            // since we use CaptureHelper in shared mode, we push this
            // view controller delegate to the CaptureHelper delegates stack
            CaptureHelper.sharedInstance.pushDelegate(self)
        }
        showSoftScanOverlay = false
        displayScanners()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // if we are showing the SoftScan Overlay view we don't
        // want to remove our delegate from the CaptureHelper delegates stack
        if showSoftScanOverlay == false {
            // remove all the scanner names from the list
            // because in CaptureHelper shared mode we will receive again
            // the deviceArrival for each connected scanner once this view
            // becomes active again
            scanners = []
            softScanTrigger?.isHidden = true;
            CaptureHelper.sharedInstance.popDelegate(self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onSoftScanTrigger(_ sender: AnyObject) {
        if let scanner = softScanner as CaptureHelperDevice? {
            showSoftScanOverlay = true
            scanner.setTrigger(.start, withCompletionHandler: {(result) in
                self.displayAlertForResult(result, forOperation: "SetTrigger")
                if result != .E_NOERROR {
                    self.showSoftScanOverlay = false
                }
            })
        }
        else if let device = lastDeviceConnected {
            device.setTrigger(.start, withCompletionHandler: { (result) in
                print("triggering the device returns: \(result.rawValue)")
            })
        }
    }
    
    // MARK: - Utility functions
    func displayScanners(){
        if let status = connectionStatus {
            // the main dispatch queue is required to update the UI
            // or the delegateDispatchQueue CaptureHelper property
            // can be set instead
//            DispatchQueue.main.async() {
                status.text = ""
                for scanner in self.scanners {
                    status.text = status.text! + (scanner as String) + "\n"
                }
                if(self.scanners.count == 0){
                    status.text = self.noScannerConnected
                }
//            }
        }
    }

    func displayAlertForResult(_ result: SKTResult, forOperation operation: String){
        if result != .E_NOERROR {
            let errorTxt = "Error \(result.rawValue) while doing a \(operation)"
            let alert = UIAlertController(title: "Capture Error", message: errorTxt, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - CaptureHelperDeviceDecodedDataDelegate

    func didReceiveDecodedData(_ decodedData: SKTCaptureDecodedData?, fromDevice device: CaptureHelperDevice, withResult result:SKTResult) {
        print("didReceiveDecodedData in the detail view with result: \(result.rawValue)")
        if result == .E_NOERROR {
            if let rawData = decodedData!.decodedData {
                let rawDataSize = rawData.count
                print("Size: \(rawDataSize)")
                print("data: \(rawData)")
                let str = decodedData!.stringFromDecodedData()
                print("Decoded Data \(String(describing: str))")
                DispatchQueue.main.async {
                    self.decodedData.text = str
                }
                // this code can be removed if the application is not interested by
                // the host Acknowledgment for the decoded data
                #if HOST_ACKNOWLEDGMENT
                    device.setDataConfirmationWithLed(SKTCaptureDataConfirmationLed.green, withBeep:SKTCaptureDataConfirmationBeep.good, withRumble: SKTCaptureDataConfirmationRumble.good, withCompletionHandler: {(result) in
                        if result != .E_NOERROR {
                            print("error trying to confirm the decoded data: \(result.rawValue)")
                        }
                    })
                #endif
            }
        }
    }

    // MARK: - CaptureHelperDevicePresenceDelegate

    // since we use CaptureHelper in shared mode, we receive a device Arrival
    // each time this view becomes active and there is a scanner connected
    func didNotifyArrivalForDevice(_ device: CaptureHelperDevice, withResult result:SKTResult) {
        print("didNotifyArrivalForDevice in the detail view")
        let name = device.deviceInfo.name
        if(name?.caseInsensitiveCompare("SoftScanner") == ComparisonResult.orderedSame){
            softScanTrigger.isHidden = false;
            softScanner = device
            
            // set the Overlay View context to give a reference to this controller
            if let scanner = softScanner {
                let context : [String:Any] = [SKTCaptureSoftScanContext : self]
                
                scanner.setSoftScanOverlayViewParameter(context, withCompletionHandler: { (result) in
                    self.displayAlertForResult(result, forOperation: "SetOverlayView")
                })
            }
        }
        else {
            lastDeviceConnected = device
            softScanTrigger.isHidden = false;
        }
        scanners.append(device.deviceInfo.name!)
        displayScanners()
    }

    func didNotifyRemovalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("didNotifyRemovalForDevice in the detail view")
        var newScanners : [String] = []
        for scanner in scanners{
            if(scanner as String != device.deviceInfo.name){
                newScanners.append(scanner as String)
            }
        }
        // if the scanner that is removed is SoftScan then
        // we nil its reference
        if softScanner != nil {
            if softScanner == device {
                softScanner = nil
            }
        }
        scanners = newScanners
        displayScanners()
    }
    
    
}
