//
//  CaptureHelperExtension.swift
//  SingleEntrySwift
//
//
//  This file is just an example to show how to extend CaptureHelper
//  using swift to send a get or set property
//
//
//  Created by Eric Glaenzer on 9/22/16.
//  Copyright © 2016 Socket Mobile, Inc. All rights reserved.
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

import Foundation
import CaptureSDK

extension CaptureHelper
{
    // this makes the scanner vibrate if vibrate mode is supported by the scanner
    func setDataConfirmationOkDevice(_ device: CaptureHelperDevice, withCompletionHandler completion: @escaping(_ result: SKTResult)->Void){
        // the Capture API requires to create a property object
        // that should be initialized accordingly to the property ID
        // that we are trying to set (or get)
        let property = SKTCaptureProperty()
        property.id = .dataConfirmationDevice
        property.type = .ulong
        property.uLongValue = UInt(SKTHelper.getDataComfirmation(withReserve: 0, withRumble: Int(SKTCaptureDataConfirmationRumble.good.rawValue), withBeep: Int(SKTCaptureDataConfirmationBeep.good.rawValue), withLed: Int(SKTCaptureDataConfirmationLed.green.rawValue)))
        
        // make sure we have a valid reference to the Capture API
        if let capture = captureApi {
            capture.setProperty(property, completionHandler: {(result, propertyResult)  in
                completion(result)
            })
        } else {
            // if the Capture API is not valid often because
            // capture hasn't be opened
            completion(SKTCaptureErrors.E_INVALIDHANDLE)
        }
    }
}
