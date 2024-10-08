//
//  SingleEntry.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 24.03.22.
//  Copyright © 2022 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import UIKit
import CaptureSDK

class SingleEntryViewController: UIViewController {
  
    @IBOutlet var connectionStatus: UILabel?
    @IBOutlet var statusLabel: UILabel?
    @IBOutlet var decodedData: UITextField?
    @IBOutlet var socketCamTriggerC820: UIButton?
    @IBOutlet var socketCamTriggerC860: UIButton?
    @IBOutlet var socketCamTriggerC820Custom: UIButton?
    @IBOutlet var socketCamTriggerC860Custom: UIButton?
    @IBOutlet var customView: UIView?

    let noScannerConnected = "No scanner connected"
    var scanners : [String] = []  // keep a list of scanners to display in the status
    var socketCamC820 : CaptureHelperDevice?  // keep a reference on the SocketCam Scanner
    var socketCamC860 : CaptureHelperDevice?  // keep a reference on the SocketCam Scanner
    var lastDeviceConnected : CaptureHelperDevice?
    var detailItem: AnyObject?
    var objects = NSMutableArray()
    var timer: Timer?

    // Reference on the SocketCam View Controller returned by SetTrigger property on a SocketCan device (C820 or C860) in order to dismiss later on after getting decoded data
    // It can be displayed: , as a popover or as a subview in your app flow.
    // Full screen: https://docs.socketmobile.com/capture/ios/en/latest/socketCam.html#sample-code-for-socketcam-presented-in-full-screen
    // As a subview: https://docs.socketmobile.com/capture/ios/en/latest/socketCam.html#sample-code-for-socketcam-presented-as-a-subview
    // As a popover: https://docs.socketmobile.com/capture/ios/en/latest/socketCam.html#sample-code-for-socketcam-presented-as-a-popover
    
    var socketCamViewController: UIViewController?
    
    // Capture Helper shareInstance allows to share
    // the same instance of Capture Helper with the
    // entire application. That static property can
    // be used in any views but it is recommended
    // to open only once Capture Helper (in the main
    // view controller) and pushDelegate, popDelegate
    // each time a new view requiring scanning capability
    // is loaded or unloaded respectively.
    var captureHelper = CaptureHelper.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        socketCamTriggerC820?.isHidden = true
        socketCamTriggerC860?.isHidden = true
        socketCamTriggerC820Custom?.isHidden = true
        socketCamTriggerC860Custom?.isHidden = true
        if #available(iOS 13, *) {
            decodedData?.overrideUserInterfaceStyle = .light
        }

        customView?.isHidden = true
        customView?.translatesAutoresizingMaskIntoConstraints = false

        openCapture()
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panPiece(_:)))
        customView?.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // since we use CaptureHelper in shared mode, we push this
        // view controller delegate to the CaptureHelper delegates stack
        CaptureHelper.sharedInstance.pushDelegate(self)
        displayScanners()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // remove all the scanner names from the list
        // because in CaptureHelper shared mode we will receive again
        // the deviceArrival for each connected scanner once this view
        // becomes active again
        scanners = []
        socketCamTriggerC820?.isHidden = true
        socketCamTriggerC820Custom?.isHidden = true
        socketCamTriggerC860?.isHidden = true
        socketCamTriggerC860Custom?.isHidden = true
        CaptureHelper.sharedInstance.popDelegate(self)
    }

    func openCapture() {
        // fill out the App Info with the Bundle ID which should start by the
        // platform on which the application is running and followed with the
        // case sensitive application Bundle ID,
        // with the Socket Mobile Portal developer ID
        // and with the Application Key generated from the Socket Mobile Developer
        // portal https://www.socketmobile.com/developers/portal
        let AppInfo = SKTAppInfo()
        AppInfo.appKey = "Your APP KEY here"
        AppInfo.appID = "ios:com.socketmobile.SingleEntrySwift"
        AppInfo.developerID = "Your Developer ID here"

        // there is a stack of delegates the last push is the
        // delegate active, when a new view requiring notifications from the
        // scanner, then push its delegate and pop its delegate when the
        // view is done
        captureHelper.pushDelegate(self)
        
        // to make all the delegates able to update the UI without the app
        // having to dispatch the UI update code, set the dispatchQueue
        // property to the DispatchQueue.main
        captureHelper.dispatchQueue = DispatchQueue.main

        // open Capture Helper only once in the application
        captureHelper.openWithAppInfo(AppInfo, withCompletionHandler: { (_ result: SKTResult) in
            print("Result of Capture initialization: \(result.rawValue)")
            // if you don't need host Acknowledgment, and use the
            // scanner acknowledgment, then these few lines can be
            // removed (from the #if to the #endif)
            #if HOST_ACKNOWLEDGMENT
                captureHelper.setConfirmationMode(confirmationMode: .modeApp, withCompletionHandler: { (result) in
                    print("Data Confirmation Mode returns : \(result.rawValue)")
                })
            // to remove the Host Acknowledgment if it was set before
            // put back to the default Scanner Acknowledgment also called Local Acknowledgment
            #else
                self.captureHelper.setConfirmationMode(.modeDevice, withCompletionHandler: { (result) in
                    print("Data Confirmation Mode returns : \(result.rawValue)")
                })
            #endif
        })
    }

    @IBAction func socketCamC820Action(_ sender: AnyObject) {
        decodedData?.resignFirstResponder()
        decodedData?.text = ""
        if let scanner = socketCamC820 as CaptureHelperDevice? {
            scanner.setTrigger(.start) { result, propertyObject in
                self.displayAlertForResult(result, forOperation: "SetTrigger")
                DispatchQueue.main.async {
                    if let anObject = propertyObject?.object, let dic = anObject as? [String: Any], let objectType = dic["SKTObjectType"] as? String, objectType == "SKTSocketCamViewControllerType", let vc = dic["SKTSocketCamViewController"] as? UIViewController {
                        vc.modalPresentationStyle = .overCurrentContext
                        self.present(vc, animated: true)
                        self.socketCamViewController = vc
                    }
                }
            }
        }
    }

    @IBAction func socketCamC820CustomAction(_ sender: AnyObject) {
        decodedData?.resignFirstResponder()
        decodedData?.text = ""
        if let scanner = socketCamC820 as CaptureHelperDevice? {
            scanner.setTrigger(.start) { result, propertyObject in
                self.displayAlertForResult(result, forOperation: "SetTrigger")
                DispatchQueue.main.async {
                    if let anObject = propertyObject?.object, let dic = anObject as? [String: Any], let objectType = dic["SKTObjectType"] as? String, objectType == "SKTSocketCamViewControllerType", let vc = dic["SKTSocketCamViewController"] as? UIViewController {
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            self.customView?.isHidden = false
                            vc.view.frame = self.customView?.bounds ?? CGRect.zero
//                            vc.view.frame = CGRect(x: 0, y: 0, width: self.customView?.frame.width, height: self.customView?.frame.height)
                            self.customView?.addSubview(vc.view)
                        } else {
                            vc.modalPresentationStyle = .popover
                            let popOverVC = vc.popoverPresentationController
                            popOverVC?.delegate = self
                            popOverVC?.sourceView = self.decodedData
                            vc.preferredContentSize = CGSize(width: 250, height: 250)
                            self.present(vc, animated: true)
                        }
                        self.socketCamViewController = vc
                    }
                }
            }
        }
    }

    @IBAction func socketCamC860Action(_ sender: AnyObject) {
        decodedData?.resignFirstResponder()
        decodedData?.text = ""

        if let scanner = socketCamC860 as CaptureHelperDevice? {
            scanner.setTrigger(.start, withCompletionHandler: { result, propertyObject in
                self.displayAlertForResult(result, forOperation: "SetTrigger")
                DispatchQueue.main.async {
                    if let anObject = propertyObject?.object, let dic = anObject as? [String: Any], let objectType = dic["SKTObjectType"] as? String, objectType == "SKTSocketCamViewControllerType", let vc = dic["SKTSocketCamViewController"] as? UIViewController {
                        vc.modalPresentationStyle = .overCurrentContext
                        self.present(vc, animated: true)
                        self.socketCamViewController = vc
                    }
                }
            })
        }
        else if let device = lastDeviceConnected {
            device.setTrigger(.start, withCompletionHandler: { result, propertyResult in
                print("triggering the device returns: \(result.rawValue)")
            })
        }
    }

    @IBAction func socketCamC860CustomAction(_ sender: AnyObject) {
        decodedData?.resignFirstResponder()
        decodedData?.text = ""

        if let scanner = socketCamC860 as CaptureHelperDevice? {
            scanner.setTrigger(.start, withCompletionHandler: { result, propertyObject in
                self.displayAlertForResult(result, forOperation: "SetTrigger")
                DispatchQueue.main.async {
                    if let anObject = propertyObject?.object, let dic = anObject as? [String: Any], let objectType = dic["SKTObjectType"] as? String, objectType == "SKTSocketCamViewControllerType", let vc = dic["SKTSocketCamViewController"] as? UIViewController {
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            self.customView?.isHidden = false
                            vc.view.frame = self.customView?.bounds ?? CGRect.zero
                            self.customView?.addSubview(vc.view)
                        } else {
                            vc.modalPresentationStyle = .popover
                            let popOverVC = vc.popoverPresentationController
                            popOverVC?.delegate = self
                            popOverVC?.sourceView = self.decodedData
                            vc.preferredContentSize = CGSize(width: 250, height: 250)
                            self.present(vc, animated: true)
                        }
                        self.socketCamViewController = vc
                    }
                }
            })
        }
        else if let device = lastDeviceConnected {
            device.setTrigger(.start, withCompletionHandler: { result, propertyResult in
                print("triggering the device returns: \(result.rawValue)")
            })
        }
    }

    private var initialCenter: CGPoint = .zero

    @objc
    @IBAction func panPiece(_ sender : UIPanGestureRecognizer) {
       guard sender.view != nil else {return}
       
        switch sender.state {
        case .began:
            initialCenter = customView?.center ?? CGPointZero
        case .changed:
            let translation = sender.translation(in: view)
            customView?.center = CGPoint(x: initialCenter.x + translation.x,
                                          y: initialCenter.y + translation.y)
        default:
            break
        }
    }

    // MARK: - Utility functions

    func displayScanners(){
        if let status = connectionStatus {
            // the main dispatch queue is required to update the UI
            // or the delegateDispatchQueue CaptureHelper property
            // can be set instead
            DispatchQueue.main.async() {
                status.text = ""
                for scanner in self.scanners {
                    status.text = status.text! + (scanner as String) + "\n"
                }
                if(self.scanners.count == 0){
                    status.text = self.noScannerConnected
                }
            }
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

    // MARK: - Helper functions

    func displayBatteryLevel(_ level: UInt?, fromDevice device: CaptureHelperDevice, withResult result: SKTResult) {
        if result != .E_NOERROR {
            print("error while getting the device battery level: \(result.rawValue)")
        }
        else{
            let battery = SKTHelper.getCurrentLevel(fromBatteryLevel: Int(level!))
            print("the device \((device.deviceInfo.name)! as String) has a battery level: \(String(describing: battery))%")
        }
    }

}

extension SingleEntryViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}
