//
//  BLEManager.swift
//  BLEManager
//
//  Created by Christos Bimpas on 23/09/2016.
//  Copyright © 2016 Snepo. All rights reserved.
//

import Foundation
import CoreBluetooth
import QuartzCore

public protocol BLEManagerDelegate {
    func BluetoothDidConnect()
    func BluetoothIsSearching()
    func BluetoothEnabled()
    func BluetoothDisabled()
}

public class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: - Constants
    let SERVICE_UUID = "00002220-0000-1000-8000-00805f9b34fb" //SERVICE
    let RECEIVE_UUID = "00002221-0000-1000-8000-00805f9b34fb" //CHARACTERISTIC
    let SEND_UUID = "00002222-0000-1000-8000-00805f9b34fb" //CHARACTERISTIC
    let DEFAULTS_KEY = "bluetooth-uuid-array"
    let GET_INFO = 0x30
    let PLAY_PATTERN = 0x31
    
    // MARK: - Properties
    public static let sharedInstance = BLEManager()
    public var delegate: BLEManagerDelegate?

    var wxCentralManager: CBCentralManager!
    
    var advertisingNames: [String]!
    
    var peripherals: [WXPeripheral] = []
    
    override init() {

    }
    
    public func initWithAdvertisingNames(names: [String]) {
        advertisingNames = names
        wxCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
//    public func getInfo() {
//        let data: [UInt8] = [0xff,0x30]
//        _peripheral.writeValue(NSData.init(bytes: data, length: 2) as Data, for: sendCharacteristic, type: CBCharacteristicWriteType.withResponse)
//    }
    
    public func sendData(data: NSData) {
        for wxPeripheral in peripherals {
            wxPeripheral.dataToWrite.append(data)
        }
        self.sendNextCommand()
    }
    
    public func sendDataToPeripheral(data: NSData, wxPeripheral: WXPeripheral) {
        wxPeripheral.dataToWrite.append(data)
        self.sendNextCommand()
    }
    
    public func cancelConnections() {
        for wxPeripheral in peripherals {
            wxCentralManager.cancelPeripheralConnection(wxPeripheral.peripheral)
        }
        peripherals.removeAll()
        peripherals = []
        wxCentralManager.stopScan()
    }
    
    public func startScanning() {
        self.delegate?.BluetoothIsSearching()
        if (wxCentralManager.state == .poweredOn) {
            wxCentralManager.scanForPeripherals(withServices: [CBUUID.init(string: SERVICE_UUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            //Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(connectToClosestPeripherals), userInfo:nil, repeats: false)
        }
    }
    
    public func clearPairing() {
        UserDefaults.standard.setValue([], forKey: DEFAULTS_KEY)
        UserDefaults.standard.synchronize()
        self.cancelConnections()
        self.startScanning()
    }
    
    public func peripheralsArray() -> [WXPeripheral] {
        return peripherals
    }
    
    private func paired() -> Bool {
        let uuidArray = UserDefaults.standard.object(forKey: DEFAULTS_KEY) as? [String]
        var isPaired: Bool = false
        for uuidString in uuidArray! {
            if uuidString.characters.count > 0 {
                isPaired = true
            }
            if isPaired {
                break
            }
        }
        return isPaired
    }
    
    private func bluetoothEnabled() -> Bool {
        return wxCentralManager.state == .poweredOn
    }
    
    private func sendNextCommand() {
        for wxPeripheral in peripherals {
            if (wxPeripheral.canWrite && wxPeripheral.connected && wxPeripheral.sendCharacteristic != nil) {
                if wxPeripheral.dataToWrite.count > 0 {
                    print("write data to peripheral")
                    let data = wxPeripheral.dataToWrite.first
                    wxPeripheral.peripheral.writeValue(data as! Data, for: wxPeripheral.sendCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                    wxPeripheral.canWrite = false
                    wxPeripheral.dataToWrite.removeFirst()
                }
            }
        }
       
    }
    
    @available(iOS 10.0, *)
    private func getBluetoothState() -> CBManagerState {
        return wxCentralManager.state
    }
    
    @objc private func connectToClosestPeripherals() {
        wxCentralManager.stopScan()
        let uuidArray = UserDefaults.standard.object(forKey: DEFAULTS_KEY) as? [String]
        if let array = uuidArray {
            for uuidString in array {
                var closestPeripheral: WXPeripheral?
                if uuidString.characters.count > 0 {
                    for wxPeripheral in peripherals {
                        if uuidString.characters.count > 0 {
                            if wxPeripheral.uuid == uuidString {
                                closestPeripheral = wxPeripheral
                            }
                        } else {
                            if (closestPeripheral == nil || wxPeripheral.RSSI > (closestPeripheral?.RSSI)!) {
                                closestPeripheral = wxPeripheral
                            }
                        }
                    }
                }
                if let wxPeripheral = closestPeripheral {
                    wxCentralManager.connect(wxPeripheral.peripheral, options: nil)
                    
                    let (uuidExists, amendedArray) = self.uuidExists(uuid: wxPeripheral.uuid)
                    if !uuidExists {
                        UserDefaults.standard.set(amendedArray, forKey: DEFAULTS_KEY)
                        UserDefaults.standard.synchronize()
                    }
                }
            }
        }
       
    }
    
    private func uuidExists(uuid: String) -> (uuidExists: Bool, amendedArray: [String]?) {
        var uuidArray = UserDefaults.standard.object(forKey: DEFAULTS_KEY) as? [String]
        var uuidExists: Bool = false
        if let array = uuidArray {
            for uuidString in array {
                if uuidString == uuid {
                    uuidExists = true
                    break
                }
            }
            if !uuidExists {
                uuidArray?.append(uuid)
            }
        }
        
        
        return (uuidExists, uuidArray)
    }
    
    // MARK: - CBCentralManagerDelegate
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            self.startScanning()
            self.delegate?.BluetoothEnabled()
        case .poweredOff:
            self.cancelConnections()
            self.delegate?.BluetoothDisabled()
        default:
            break
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let advertisingName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        print(advertisingName)
        for wxAdvertisingName in advertisingNames {
            
            if advertisingName == wxAdvertisingName {
                let wxPeripheral = WXPeripheral.init(peripheral: peripheral, name: wxAdvertisingName, uuid: peripheral.identifier.uuidString, RSSI: RSSI.intValue)
                peripherals.append(wxPeripheral)
                wxCentralManager.stopScan()
                wxCentralManager.connect(wxPeripheral.peripheral, options: nil)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.cancelConnections()
        self.startScanning()
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.delegate?.BluetoothDidConnect()
        
        for wxPeripheral in peripherals {
            if wxPeripheral.uuid == peripheral.identifier.uuidString {
                wxPeripheral.connected = true
            }
        }
        
        let (uuidExists, amendedArray) = self.uuidExists(uuid: peripheral.identifier.uuidString)

        if !uuidExists {
            UserDefaults.standard.set(amendedArray, forKey: DEFAULTS_KEY)
            UserDefaults.standard.synchronize()
        }
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        peripheral.discoverServices([CBUUID.init(string: RECEIVE_UUID),CBUUID.init(string: SEND_UUID)])
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.delegate?.BluetoothIsSearching()
        self.startScanning()
    }
    
    // MARK: - CBPeripheralDelegate
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil { return }
        
        for service: CBService in peripheral.services! {
            peripheral.discoverCharacteristics([CBUUID.init(string: RECEIVE_UUID),CBUUID.init(string: SEND_UUID)], for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic: CBCharacteristic in service.characteristics! {
            if characteristic.uuid.uuidString == "2221" {
                for wxPeripheral in peripherals {
                    if wxPeripheral.uuid == peripheral.identifier.uuidString {
                        wxPeripheral.receiveCharacteristic = characteristic
                        wxPeripheral.peripheral.setNotifyValue(true, for: wxPeripheral.receiveCharacteristic!)
                        
                    }
                }
            } else if characteristic.uuid.uuidString == "2222" {
                for wxPeripheral in peripherals {
                    if wxPeripheral.uuid == peripheral.identifier.uuidString {
                        wxPeripheral.sendCharacteristic = characteristic
                        wxPeripheral.canWrite = true
                    }
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error == nil {
            for wxPeripheral in peripherals {
                if wxPeripheral.uuid == peripheral.identifier.uuidString {
                    wxPeripheral.canWrite = true
                }
            }
            self.sendNextCommand()
        }
    }
    
}
