//
//  SwiftUIViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 06.07.22.
//  Copyright © 2022 Socket Mobile, Inc. All rights reserved.
//

import CaptureSDK
import Foundation
import SwiftUI


struct ContentView: View {

    @ObservedObject var socketCamBind: SocketCamBind

    var body: some View {
        VStack {
            Spacer()
            Text("This is a SwiftUI view 🚀🚀🚀")
            Spacer()
            Button("Trigger SocketCam C820") {
                
                // Triggers SocketCam from this SwiftUI view
                // Here we get the "socketCam" object passed from the main view controller from the binding object
                socketCamBind.socketCam?.setTrigger(SKTCaptureTrigger.start, withCompletionHandler: { (result) in
                    if result != .E_NOERROR {
                        print("There's an error: \(result.rawValue)")
                    }
                })
            }
            
            // If the decoded string from the delegate is not empty we display a Text
            if socketCamBind.decodedtring.count > 0 {
                Spacer()
                Text("The decoded string is:\n" + socketCamBind.decodedtring)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Spacer()
            Spacer()
        }
    }

}
