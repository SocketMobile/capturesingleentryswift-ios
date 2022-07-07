//
//  SocketCamBind.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 07.07.22.
//  Copyright © 2022 Socket Mobile, Inc. All rights reserved.
//

import CaptureSDK

// This object contains the SocketCam instance and the decoded string
// that can be observed by a SwiftUI view as an @ObservedObject

@available(iOS 14.0, *)
class SocketCamBind: ObservableObject {

    @Published var socketCam: CaptureHelperDevice?

    @Published var decodedtring: String = ""
    
}

