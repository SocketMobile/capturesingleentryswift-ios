//
//  TriggerViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 10.10.25.
//  Copyright © 2025 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import UIKit
import CaptureSDK


class TriggerViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var startButton: UIButton?
    @IBOutlet var stopButton: UIButton?
    @IBOutlet var continuousButton: UIButton?
    @IBOutlet var customView: UIView?

    var device: CaptureHelperDevice?
    
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
        
        self.title = "Trigger feature"
        self.titleLabel?.text = device?.deviceInfo.name
        
        if device?.deviceInfo.deviceType == .socketCamC820 || device?.deviceInfo.deviceType == .socketCamC860 {
            startButton?.setTitle("Set Trigger SocketCam full screen", for: .normal)
            continuousButton?.setTitle("Set Trigger SocketCam custom view", for: .normal)
        }
        
        stopButton?.isHidden = device?.deviceInfo.deviceType == .socketCamC820 || device?.deviceInfo.deviceType == .socketCamC860

        customView?.isHidden = true
        customView?.translatesAutoresizingMaskIntoConstraints = false

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panPiece(_:)))
        customView?.addGestureRecognizer(panGestureRecognizer)

        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveDecodedData), name: NSNotification.Name("didReceiveDecodedDataSuccess"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveDecodedDataCancel), name: NSNotification.Name("didReceiveDecodedDataCancel"), object: nil)
    }
    
    @IBAction func triggerStartAction() {
        if let device = device {
            if device.deviceInfo.deviceType == .socketCamC820 || device.deviceInfo.deviceType == .socketCamC860 {
                device.setTrigger(.start) { result, propertyObject in
                    DispatchQueue.main.async {
                        if let anObject = propertyObject?.object, let dic = anObject as? [String: Any], let objectType = dic["SKTObjectType"] as? String, objectType == "SKTSocketCamViewControllerType", let vc = dic["SKTSocketCamViewController"] as? UIViewController, result == .E_NOERROR {
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(vc, animated: true)
                            self.socketCamViewController = vc
                        }
                    }
                }
            } else {
                device.setTrigger(.start) { result, propertyResult in
                    print("Set trigger Start - Result: \(result.rawValue)")
                }
            }
        }
    }
    
    @IBAction func triggerStopAction() {
        if let device = device {
            device.setTrigger(.stop) { result, propertyResult in
                print("Set trigger Stop - Result: \(result.rawValue)")
            }
        }
    }

    @IBAction func triggerContinuousScanAction() {
        if let device = device {
            if device.deviceInfo.deviceType == .socketCamC820 || device.deviceInfo.deviceType == .socketCamC860 {
                device.setTrigger(.continuousScan) { result, propertyObject in
                    DispatchQueue.main.async {
                        if let anObject = propertyObject?.object, let dic = anObject as? [String: Any], let objectType = dic["SKTObjectType"] as? String, objectType == "SKTSocketCamViewControllerType", let vc = dic["SKTSocketCamViewController"] as? UIViewController, result == .E_NOERROR {
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                self.customView?.isHidden = false
                                vc.view.frame = self.customView?.bounds ?? CGRect.zero
                                self.customView?.addSubview(vc.view)
                            } else {
                                vc.modalPresentationStyle = .popover
                                let popOverVC = vc.popoverPresentationController
                                popOverVC?.delegate = self
                                popOverVC?.sourceView = self.continuousButton
                                vc.preferredContentSize = CGSize(width: 300, height: 300)
                                self.present(vc, animated: true)
                            }
                            self.socketCamViewController = vc
                        }
                    }
                }
            } else {
                device.setTrigger(.continuousScan) { result, propertyResult in
                    print("Set trigger Continuous - Result: \(result.rawValue)")
                }
            }
        }
    }

    @objc
    func didReceiveDecodedData(_ notification: Notification) {
        closeSocketCam()
    }


    @objc
    func didReceiveDecodedDataCancel(_ notification: Notification) {
        closeSocketCam()
    }

    private func closeSocketCam() {
        DispatchQueue.main.async {
            self.socketCamViewController?.dismiss(animated: true, completion: {
                self.socketCamViewController = nil
            })
            self.socketCamViewController?.view.removeFromSuperview()
            self.customView?.isHidden = true
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

}


extension TriggerViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}
