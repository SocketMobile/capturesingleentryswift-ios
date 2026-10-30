//
//  DevicesViewController.swift
//  SingleEntrySwift
//
//  Created by Cyrille on 10.10.25.
//  Copyright © 2025 Socket Mobile, Inc. All rights reserved.
//

import Foundation
import UIKit
import CaptureSDK


class DevicesViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView?

    var devices: [CaptureHelperDevice] = []
    var discoveredDevices: [SKTCaptureDiscoveredDeviceInfo] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""

        NotificationCenter.default.addObserver(self, selector: #selector(didNotifyArrivalForDevice), name: NSNotification.Name("didNotifyArrivalForDevice"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didNotifyRemovalForDevice), name: NSNotification.Name("didNotifyRemovalForDevice"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDiscoverDevice), name: NSNotification.Name("didDiscoverDevice"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEndDiscoveryWithResult), name: NSNotification.Name("didEndDiscoveryWithResult"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(didNotifyArrivalForCoupler), name: NSNotification.Name("didNotifyArrivalForCoupler"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didNotifyRemovalForCoupler), name: NSNotification.Name("didNotifyRemovalForCoupler"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(didNotifyArrivalForTag), name: NSNotification.Name("didNotifyArrivalForTag"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didNotifyRemovalForTag), name: NSNotification.Name("didNotifyRemovalForTag"), object: nil)
    }
    
    @objc
    func didNotifyArrivalForDevice(notification: NSNotification) {
        if let device: CaptureHelperDevice = notification.object as? CaptureHelperDevice {
            if !devices.contains(where: { deviceToCompare in
                return device.deviceInfo.guid == deviceToCompare.deviceInfo.guid
            }) {
                devices.append(device)
            }
        }
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    @objc
    func didNotifyRemovalForDevice(notification: NSNotification) {
        if let device: CaptureHelperDevice = notification.object as? CaptureHelperDevice {
            if let index = devices.firstIndex(of: device) {
                devices.remove(at: index)
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }

    @objc
    func didNotifyArrivalForCoupler(notification: NSNotification) {
        if let device: CaptureHelperDevice = notification.object as? CaptureHelperDevice {
            if !devices.contains(where: { deviceToCompare in
                return device.deviceInfo.guid == deviceToCompare.deviceInfo.guid
            }) {
                devices.append(device)
            }
        }
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }

    @objc
    func didNotifyRemovalForCoupler(notification: NSNotification) {
        if let device: CaptureHelperDevice = notification.object as? CaptureHelperDevice {
            if let index = devices.firstIndex(of: device) {
                devices.remove(at: index)
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }

    @objc
    func didNotifyArrivalForTag(notification: NSNotification) {
        if let device: CaptureHelperDevice = notification.object as? CaptureHelperDevice {
            if !devices.contains(where: { deviceToCompare in
                return device.deviceInfo.guid == deviceToCompare.deviceInfo.guid
            }) {
                devices.append(device)
            }
        }
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }

    @objc
    func didNotifyRemovalForTag(notification: NSNotification) {
        if let device: CaptureHelperDevice = notification.object as? CaptureHelperDevice {
            if let index = devices.firstIndex(of: device) {
                devices.remove(at: index)
            }
        }
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }

    @objc
    func didDiscoverDevice(_ notification: Notification) {
        if let device = notification.object as? SKTCaptureDiscoveredDeviceInfo {
            if !discoveredDevices.contains(where: { deviceToCompare in
                return device.identifierUuid == deviceToCompare.identifierUuid
            }) {
                discoveredDevices.append(device)
            }
        }
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }

    @objc
    func didEndDiscoveryWithResult(_ notification: Notification) {
        // If there's no discovered Bluetooth LE you can launch a Bluetooth Classic discovery for instance
        // This use the iOS native picker and the device will connect automatically to the CaptureSDK and your app
    }

    @IBAction func addBleDeviceAction() {
        // First we launch a Bluetooth LE discovery in this sample app
        // PLEASE NOTE THAT OUR DEVICES ARE MAINLY BLUETOOTH CLASSIC AND WE'RE TRANSITIONING TO BLUETOOTH LOW ENERGY DEVICES
        // THINK ABOUT DOING A BLUETOOTH CLASSIC DISCOVERY AS YOUR CUSTOMERS MAY STILL HAVE THOSE DEVICES FOR A WHILE
        // SO YOU CAN START WITH BLUETOOTH CLASSIC FIRST IF YOU WANT TO
        CaptureHelper.sharedInstance.addBluetoothDevice(.bluetoothLowEnergy , withCompletionHandler: { result in
            print("Add Bluetooth Low Energy Device result: \(result.rawValue)")
        })
    }

    @IBAction func addBluetoothClassicDeviceAction() {
        // You can also launch a Bluetooth Classic discovery through the External Accessory framework in this sample app
        // This use the iOS native picker and the device will connect automatically to the CaptureSDK and your app
        // PLEASE NOTE THAT OUR DEVICES ARE MAINLY BLUETOOTH CLASSIC AND WE'RE TRANSITIONING TO BLUETOOTH LOW ENERGY DEVICES
        CaptureHelper.sharedInstance.addBluetoothDevice(.bluetoothClassic , withCompletionHandler: { result in
            print("Add Bluetooth Classic Device result: \(result.rawValue)")
        })
    }
    
    @IBAction func setPartnershipAction() {
        if let setPartnershipViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SinglePartnershipViewController") as? SinglePartnershipViewController {
            setPartnershipViewController.device = nil
            self.navigationController?.pushViewController(setPartnershipViewController, animated: true)
        }

    }

}


extension DevicesViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Connected Devices"
        case 1:
            return discoveredDevices.count > 0 ? "Discovered Devices" : ""
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return devices.count
        case 1:
            return discoveredDevices.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row < devices.count, devices[indexPath.row].deviceInfo.deviceType == .nfcTag {
                if let cell: TagDeviceCell = tableView.dequeueReusableCell(withIdentifier: "TagDeviceCell", for: indexPath) as? TagDeviceCell {
                    let device = devices[indexPath.row]
                    cell.tagDevice = device
                    cell.nameLabel.text = device.deviceInfo.name
                    cell.completion = {
                        if let index = self.devices.firstIndex(of: device) {
                            self.devices.remove(at: index)
                            DispatchQueue.main.async {
                                self.tableView?.reloadData()
                            }
                        }
                    }
                    return cell
                }
            } else if let cell: ConnectedDeviceCell = tableView.dequeueReusableCell(withIdentifier: "ConnectedDeviceCell", for: indexPath) as? ConnectedDeviceCell {
                if devices.count > 0 {
                    let device = devices[indexPath.row]
                    cell.device = device
                    cell.nameLabel.text = device.deviceInfo.name
                    cell.actionButton.isHidden = device.deviceInfo.deviceType == .socketCamC820 || device.deviceInfo.deviceType == .socketCamC860
                    cell.completion = {
                        if let index = self.devices.firstIndex(of: device) {
                            self.devices.remove(at: index)
                            DispatchQueue.main.async {
                                self.tableView?.reloadData()
                            }
                        }
                    }
                }
                return cell
            }
        case 1:
            if let cell: DiscoveredDeviceCell = tableView.dequeueReusableCell(withIdentifier: "DiscoveredDeviceCell", for: indexPath) as? DiscoveredDeviceCell {
                if discoveredDevices.count > 0 {
                    let device = discoveredDevices[indexPath.row]
                    cell.device = device
                    cell.nameLabel.text = device.name
                    cell.completion = {
                        if let index = self.discoveredDevices.firstIndex(of: device) {
                            self.discoveredDevices.remove(at: index)
                            DispatchQueue.main.async {
                                self.tableView?.reloadData()
                            }
                        }
                    }
                }
                return cell
            }
        default:
            return UITableViewCell()
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64.0
    }
}


extension DevicesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, let featuresViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeaturesViewController") as? FeaturesViewController {
            featuresViewController.device = devices[indexPath.row]
            self.navigationController?.pushViewController(featuresViewController, animated: true)
        }
    }

}


class ConnectedDeviceCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var actionButton: UIButton!
    
    weak var device: CaptureHelperDevice?
    var completion: (() -> Void)?
    
    @IBAction func disconnectAction() {
        if let device = self.device {
            // Removing a device is made at the CaptureHelper level like the 'addBluetoothDevice'
            CaptureHelper.sharedInstance.removeBluetoothDevice(device.deviceInfo.guid ?? "") { result in
                print("removeBluetoothDevice: \(device.deviceInfo.name ?? "") - Result: \(result.rawValue)")
                if result == .E_NOERROR, let completion = self.completion {
                    completion()
                }
            }
        }
    }
}


class DiscoveredDeviceCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var actionButton: UIButton!
    
    weak var device: SKTCaptureDiscoveredDeviceInfo?
    var completion: (() -> Void)?
    
    @IBAction func connectAction() {
        if let device = self.device {
            // Connecting a Bluetooth LE device happens with the Bluetooth LE device manager. Bluetooth Classic devices are connected at the iOS Settings level once discovered and selected through the iOs native picker
            CaptureHelper.sharedInstance.connectToDiscoveredDevice(device) { result in
                print("connectToDiscoveredDevice: \(device.name ?? "") - Result: \(result.rawValue)")
                if result == .E_NOERROR, let completion = self.completion {
                    completion()
                }
            }
        }
    }

}


class TagDeviceCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!

    weak var tagDevice: CaptureHelperDevice?
    var completion: (() -> Void)?
    
    @IBAction func readTagAction() {
        if let tagDevice = self.tagDevice {
            // In this case, device is a NFC Tag as an example
            // The NDEF area of a Type 2 tag (MIFARE Ultralight, NTAG) starts at page 4
            readNdefMessage(from: tagDevice, startingAtPage: 4, accumulated: Data())
        }
    }

    // READ BINARY returns only 16 bytes (4 pages) per command, so keep reading until the whole NDEF TLV is available
    private func readNdefMessage(from tagDevice: CaptureHelperDevice, startingAtPage page: UInt8, accumulated: Data) {
        tagDevice.transmitDataForTagWithCompletionHandler(Data([0xFF, 0xB0, 0x00, page, 0x10])) { result, response in
            // response = 16 data bytes + 90 00
            print("transmitDataForTag: \(String(describing: response)) - Result: \(result.rawValue)")
            guard result == .E_NOERROR, let response = response, response.count >= 2,
                  response.suffix(2) == Data([0x90, 0x00]) else { return }
            let tlvs = accumulated + response.dropLast(2)

            switch NdefDecoder.findNdefMessage(in: tlvs) {
            case .found(let message):
                let dataString = NdefDecoder.humanReadableText(fromNdefMessage: message)
                    ?? message.map { String(format: "%02X", $0) }.joined()
                NotificationCenter.default.post(name: NSNotification.Name("didReceiveDecodedDataSuccess"), object: dataString)
            case .needsMoreData:
                guard page <= UInt8.max - 4 else { return }
                self.readNdefMessage(from: tagDevice, startingAtPage: page + 4, accumulated: tlvs)
            case .notFound:
                print("No NDEF message found on the tag")
            }
        }
    }

    @IBAction func writeTagAction() {
        if let tagDevice = self.tagDevice {
            // NDEF TLV holding a URI record "https://socketmobile.dev" (0x04 = "https://" prefix), followed by the terminator TLV
            let ndefUrl = Data([
                0x03, 0x15, 0xD1, 0x01, 0x11, 0x55, 0x04,
                0x73, 0x6F, 0x63, 0x6B, 0x65, 0x74, 0x6D, 0x6F, 0x62, 0x69, 0x6C, 0x65,
                0x2E, 0x64, 0x65, 0x76,
                0xFE
            ])
            tagDevice.writeDataForTag(ndefUrl, startingAtPage: 4) { result, tagResponse in
                let response = tagResponse.map { $0.map { String(format: "%02X", $0) }.joined() } ?? ""
                print("Write NDEF URL - Result: \(result.rawValue) \(response)")
            }
        }
    }

}

// Minimal NFC Forum Type 2 Tag / NDEF decoding: locates the NDEF TLV and decodes its first record (URI or Text)
enum NdefDecoder {

    enum TlvScanResult {
        case found(Data)
        case needsMoreData
        case notFound
    }

    // NFC Forum URI Record Type Definition, Table 3 (URI identifier codes)
    private static let uriPrefixes = [
        "", "http://www.", "https://www.", "http://", "https://", "tel:", "mailto:",
        "ftp://anonymous:anonymous@", "ftp://ftp.", "ftps://", "sftp://", "smb://", "nfs://",
        "ftp://", "dav://", "news:", "telnet://", "imap:", "rtsp://", "urn:", "pop:", "sip:",
        "sips:", "tftp:", "btspp://", "btl2cap://", "btgoep://", "tcpobex://", "irdaobex://",
        "file://", "urn:epc:id:", "urn:epc:tag:", "urn:epc:pat:", "urn:epc:raw:", "urn:epc:",
        "urn:nfc:"
    ]

    static func findNdefMessage(in tlvs: Data) -> TlvScanResult {
        let bytes = [UInt8](tlvs)
        var index = 0
        while index < bytes.count {
            let type = bytes[index]
            if type == 0x00 { // NULL TLV has no length field
                index += 1
                continue
            }
            if type == 0xFE { // Terminator TLV
                return .notFound
            }
            guard index + 1 < bytes.count else { return .needsMoreData }
            var length = Int(bytes[index + 1])
            var valueStart = index + 2
            if length == 0xFF { // 3-byte length format
                guard index + 3 < bytes.count else { return .needsMoreData }
                length = Int(bytes[index + 2]) << 8 | Int(bytes[index + 3])
                valueStart = index + 4
            }
            let valueEnd = valueStart + length
            if type == 0x03 {
                return valueEnd <= bytes.count ? .found(Data(bytes[valueStart..<valueEnd])) : .needsMoreData
            }
            index = valueEnd
        }
        return .needsMoreData
    }

    static func humanReadableText(fromNdefMessage message: Data) -> String? {
        let bytes = [UInt8](message)
        guard bytes.count >= 3 else { return nil }
        let header = bytes[0]
        let isShortRecord = header & 0x10 != 0
        let hasIdLength = header & 0x08 != 0
        let isWellKnownType = header & 0x07 == 0x01
        let typeLength = Int(bytes[1])
        var index = 2

        let payloadLength: Int
        if isShortRecord {
            payloadLength = Int(bytes[index])
            index += 1
        } else {
            guard index + 4 <= bytes.count else { return nil }
            payloadLength = bytes[index..<index + 4].reduce(0) { $0 << 8 | Int($1) }
            index += 4
        }
        var idLength = 0
        if hasIdLength {
            guard index < bytes.count else { return nil }
            idLength = Int(bytes[index])
            index += 1
        }
        let typeEnd = index + typeLength
        let payloadStart = typeEnd + idLength
        let payloadEnd = payloadStart + payloadLength
        guard isWellKnownType, payloadLength > 0, payloadEnd <= bytes.count else { return nil }
        let firstPayloadByte = bytes[payloadStart]
        let payload = Data(bytes[payloadStart..<payloadEnd])

        switch Data(bytes[index..<typeEnd]) {
        case Data([0x55]): // "U"
            let prefix = Int(firstPayloadByte) < uriPrefixes.count ? uriPrefixes[Int(firstPayloadByte)] : ""
            return prefix + String(decoding: payload.dropFirst(), as: UTF8.self)
        case Data([0x54]): // "T": status byte (bit 7 = UTF-16, bits 0-5 = language code length) + language code + text
            let languageCodeLength = Int(firstPayloadByte & 0x3F)
            let encoding: String.Encoding = firstPayloadByte & 0x80 != 0 ? .utf16 : .utf8
            return String(data: payload.dropFirst(1 + languageCodeLength), encoding: encoding)
        default:
            return nil
        }
    }

}

