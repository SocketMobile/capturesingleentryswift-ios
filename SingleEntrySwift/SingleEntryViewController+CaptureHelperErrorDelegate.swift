//
//  SingleEntryViewController+CaptureHelperErrorDelegate.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 24.03.22.
//  Copyright © 2022 Socket Mobile, Inc. All rights reserved.
//

import CaptureSDK

extension SingleEntryViewController: CaptureHelperErrorDelegate {
    
    func didReceiveError(_ error: SKTResult) {
        print("Receive a Capture error: \(error.rawValue)")
    }

}
