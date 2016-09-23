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
    let GET_INFO = 0x30
    let PLAY_PATTERN = 0x31
    
    // MARK: - Properties
    public static let sharedInstance = BLEManager()
    public var delegate: BLEManagerDelegate?

    public var peripheralConnected: Bool!
    
    var _centralManager: CBCentralManager!
    var _peripheral: CBPeripheral!
    
    var receiveCharacteristic: CBCharacteristic!
    var sendCharacteristic: CBCharacteristic!
    
    var dataToWrite: [NSData]!
    var canWrite: Bool?
    
    // i.e. "fan jersey", "we-ex"
    public var advertisedName: String!
    
    
    override init() {
         //
    }
    
    public func initWithAdvertisedName(name: String) {
        advertisedName = name
        _centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    public func getInfo() {
        let data: [UInt8] = [0xff,0x30]
        _peripheral.writeValue(NSData.init(bytes: data, length: 2) as Data, for: sendCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }
    
    public func sendData(data: NSData) {
        dataToWrite.append(data)
        self.sendNextCommand()
    }
    
    public func cancelConnections() {
        if (_peripheral != nil) {
            _centralManager.cancelPeripheralConnection(_peripheral)
            _peripheral = nil
        }
        _centralManager.stopScan()
    }
    
    public func startScanning() {
        self.delegate?.BluetoothIsSearching()
        dataToWrite = []
        canWrite = false
        peripheralConnected = false
        _peripheral = nil
        if (_centralManager.state == .poweredOn) {
            _centralManager.scanForPeripherals(withServices: [CBUUID.init(string: SERVICE_UUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    public func clearPairing() {
        UserDefaults.standard.setValue("", forKey: "nfl-bluetooth-uuid")
        UserDefaults.standard.synchronize()
        self.cancelConnections()
        self.startScanning()
    }
    
    private func paired() -> Bool {
        let uuidString = UserDefaults.standard.object(forKey: "nfl-bluetooth-uuid") as? String
        return (uuidString?.characters.count)! > 0
    }
    
    private func bluetoothEnabled() -> Bool {
        return _centralManager.state == .poweredOn
    }
    
    private func sendNextCommand() {
        if (_peripheral == nil || !peripheralConnected || sendCharacteristic == nil) {
            return
        }
        
        if (canWrite)! {
            if dataToWrite.count > 0 {
                print("write data to peripheral")
                let data = dataToWrite.first
                _peripheral.writeValue(data as! Data, for: sendCharacteristic, type: CBCharacteristicWriteType.withResponse)
                dataToWrite.removeFirst()
            }
        }
    }
    
    @available(iOS 10.0, *)
    private func getBluetoothState() -> CBManagerState {
        return _centralManager.state
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
        let previousUUID = UserDefaults.standard.object(forKey: "nfl-bluetooth-uuid") as? String!
        
        let advertisingName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        if advertisingName == advertisedName {
            if (previousUUID == nil || previousUUID == "" || previousUUID == peripheral.identifier.uuidString) {
                _peripheral = peripheral
                _centralManager.stopScan()
                _centralManager.connect(_peripheral, options: nil)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.cancelConnections()
        self.startScanning()
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheralConnected = true
        self.delegate?.BluetoothDidConnect()
        UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: "nfl-bluetooth-uuid")
        UserDefaults.standard.synchronize()
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
                receiveCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: receiveCharacteristic)
            } else if characteristic.uuid.uuidString == "2222" {
                canWrite = true
                sendCharacteristic = characteristic
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error == nil {
            canWrite = true
            self.sendNextCommand()
        }
    }
}
