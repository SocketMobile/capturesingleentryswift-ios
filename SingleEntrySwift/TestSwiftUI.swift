//
//  TestSwiftUI.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 15.06.22.
//  Copyright © 2022 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import CaptureSDK
import SwiftUI
import Combine


@available(iOS 15, *)
struct SocketReaderBar: View, CaptureHelperDevicePresenceDelegate {
    
    func didNotifyArrivalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        guard let deviceName = device.deviceInfo.name else {return}
        let deviceType = device.deviceInfo.deviceType
        print(deviceName, deviceType)
    }
    
    func didNotifyRemovalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        
    }
    
    private var myString: String = ""
    
    var body: some View {
        return ZStack {
            HStack {
                Spacer()
                Spacer()
            }
        }
        .padding(.horizontal)
        
    }
    
}
