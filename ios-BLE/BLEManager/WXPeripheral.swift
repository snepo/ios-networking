//
//  WXPeripheral.swift
//  BLEManager
//
//  Created by Christos Bimpas on 26/09/2016.
//  Copyright © 2016 Snepo. All rights reserved.
//

import Foundation
import CoreBluetooth

public class WXPeripheral: NSObject {
    public let peripheral: CBPeripheral
    public let name: String
    public let uuid: String
    public var RSSI: Int
    public var connected: Bool = false
    public var isClosest: Bool = true
    public var receiveCharacteristic: CBCharacteristic? = nil
    public var sendCharacteristic: CBCharacteristic? = nil
    public var dataToWrite: [NSData] = []
    public var canWrite: Bool = false
    
    
    init(peripheral: CBPeripheral,name: String, uuid: String, RSSI: Int) {
        self.peripheral = peripheral
        self.name = name
        self.uuid = uuid
        self.RSSI = RSSI
    }
}
