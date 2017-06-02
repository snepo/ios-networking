//
//  GarmentManager.swift
//  nadix
//
//  Created by james on 16/2/17.
//  Copyright © 2017 Snepo. All rights reserved.
//

import Foundation
import CoreData
import CoreBluetooth

enum GarmentProcessStates {
    case idle    // initial idle state
    case connectSaved // request connection to saved peripherals
    case scanning   // scanning for local peripherals, connecting to saved peripheral UUIDs
    case activating // scan + wait before attempting to save ('activate') nearby modules to complete an outfit
}

struct PeripheralRSSI {
    var peripheral:CBPeripheral
    var RSSI:NSNumber
}

// Bluetooth Garments are remembered at the users discretion, and to the local app only.
// The garments (peripheral UUID) is based on the app installation, not per user.
class GarmentManager : NSObject {
    static let sharedManager: GarmentManager = GarmentManager()

    var delegate: GarmentCommunicationDelegate?
    
    let serviceUUIDvalue = "2220"
    let characteristicUUIDvalue = "2222"
    
    let garmentStoreKey = "garmentStoreKey"

    var centralManager : CBCentralManager!
    var startedScanning : Date?

    var nearbyNadixPeripherals : [UUID:PeripheralRSSI] = [:]
    let nearbyWaitPeriod : TimeInterval = 5.0
    
    var connectedPeripherals : [UUID:CBPeripheral] = [:]

    var activityState: GarmentProcessStates = .idle
    
    var versionNumber : Int?
    var batteryPercentage : Int?
    
    var bluetoothEnabled: Bool = false
    
    var shouldSkipConfiguration = false
    
    override private init() {
        super.init()
        centralManager = CBCentralManager.init(delegate: self, queue: nil)
    }
    
    var hasRememberedGarment : Bool {
        return Garment.mr_countOfEntities() > 0
    }
    
    func beginActivation() {
        guard activityState != .activating else {return}
        
        //start scanning if not already doing so
        switch activityState {
        case .idle: // first time 
            startScanning()
        case .connectSaved:
            nearbyNadixPeripherals = [:] //forget all past nearby nadix peripherals
            disconnectAll()
            startScanning()
        case .scanning:
            break
        case .activating: //already guarded above
            return
        }

        //ensure is scanning before waiting to connect to nearest devices
        guard activityState == .scanning else {
            return
        }
        
        activityState = .activating
        print("Activating")
        var remaining : TimeInterval = nearbyWaitPeriod
        
        if startedScanning != nil {
            let scanningSince = -startedScanning!.timeIntervalSinceNow
            remaining -= scanningSince
            remaining = max(1.0, remaining)
        }
        
        Timer.scheduledTimer(withTimeInterval: remaining, repeats: false) { _ in
            self.connectNearest(peripheralRSSIs:self.nearbyNadixPeripherals)
        }
    }
    
    func disconnectAll() {
        _ = connectedPeripherals.values.map({ self.centralManager.cancelPeripheralConnection($0) })
        connectedPeripherals = [:]
    }
    
    func isBluetoothEnabled() -> Bool {
        return bluetoothEnabled
    }
    
}

extension GarmentManager { //bluetooth
    
    @objc fileprivate func connectNearest(peripheralRSSIDictionary:NSDictionary) {
        let d = peripheralRSSIDictionary as! [UUID:PeripheralRSSI]
        connectNearest(peripheralRSSIs: d)
    }
    
    fileprivate func connectNearest(peripheralRSSIs:[UUID:PeripheralRSSI]) {
        guard peripheralRSSIs.count > 0 else {
            NotificationCenter.default.post(name: Notification.Name(Constants.NotificationKey.garmentDidStopActivation), object: self, userInfo: nil)
            connectToSaved()
            return
        }
        centralManager.stopScan()
        startedScanning = nil

        let sortedPerhipheralRSSIs = peripheralRSSIs.values.sorted(by:{ $0.RSSI.intValue > $1.RSSI.intValue })
        
        let nearestContext = NSManagedObjectContext.mr_()
        //map peripheral RSSIs to local Garments
        let orderedGarments = sortedPerhipheralRSSIs.map {
            let g = Garment.mr_createEntity(in: nearestContext)!
            g.uuid = $0.peripheral.identifier.uuidString
            g.type = GarmentType.unknown.rawValue
            return g
        } as [Garment]

        _ = saveNearestBean(orderedGarments: orderedGarments)
//        _ = saveNearestOutfit(orderedGarments: orderedGarments)
        connectToSaved()
        
    }
    
    fileprivate func connectToSaved() {
        activityState = .connectSaved
        let savedUUIDs = Garment.mr_findAll()!.map({ UUID(uuidString:($0 as! Garment).uuid!)! })
        print("CTS - savedUUIDs: \(savedUUIDs)")
        let retrievedSaved = centralManager.retrievePeripherals(withIdentifiers: savedUUIDs)
        _ = retrievedSaved.map({ connect($0) })
    }

    
    fileprivate func connect(_ peripheral:CBPeripheral) {
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
}

extension GarmentManager : CBCentralManagerDelegate {

    fileprivate func startScanning() {
        guard centralManager.state == .poweredOn else {
            activityState = .idle
            return
        }
        
        activityState = .scanning
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        startedScanning = Date()
    }
    
    //MARK: CBCentralManagerDelegate methods
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("CBCentralManagerStatePoweredOn")
            //startScanning()
            bluetoothEnabled = true
            connectToSaved()
            break
        case .poweredOff:
            print("CBCentralManagerStatePoweredOff")
            bluetoothEnabled = false
            break
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name : String = advertisementData["kCBAdvDataLocalName"] as! String? {
            print("\(name): \(RSSI.intValue). \(peripheral.identifier.uuidString)")
            if name.isEqual("NadiX") {
                nearbyNadixPeripherals[peripheral.identifier] = PeripheralRSSI(peripheral: peripheral, RSSI: RSSI)
                //connect(peripheral) // to discover type
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("DID CONNECT: \(peripheral.identifier)")
        peripheral.discoverServices(nil)
        connectedPeripherals[peripheral.identifier] = peripheral
        nearbyNadixPeripherals.removeValue(forKey: peripheral.identifier)
        
        delegate?.didConnect(peripheral.identifier)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("did fail to connect")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral")
        connectedPeripherals.removeValue(forKey: peripheral.identifier)
        delegate?.didDisconnect(peripheral.identifier)
        nearbyNadixPeripherals[peripheral.identifier] = PeripheralRSSI(peripheral: peripheral, RSSI: -200)
        if activityState == .connectSaved {
            connectToSaved()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didRetrievePeripherals peripherals: [CBPeripheral]) {
        print("*** didRetrievePeripherals: \(peripherals)")
        let savedUUIDStrings = Garment.mr_findAll()!.map({ ($0 as! Garment).uuid! })
        let savedRetrievedPeripherals = peripherals.filter({ savedUUIDStrings.contains($0.identifier.uuidString) })
        _ = savedRetrievedPeripherals.map({ connect($0) })
    }
    
}

extension GarmentManager : CBPeripheralDelegate {

    //MARK: CBPeripheralDelegate methods
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        delegate?.garment(peripheral.identifier, didReceive: data)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        if (error != nil) {
            print("error writing")
        } else {
            print("did write")
        }
    }
}

extension GarmentManager {
    func peripheralForUUIDString(_ uuidString:String) -> CBPeripheral? {
        guard let uuid = UUID(uuidString:uuidString) else { return nil }
        return self.connectedPeripherals[uuid]
    }
    
    func send(_ uuidString:String, message : UInt8) {
        var msg = message
        let data = NSData.init(bytes: &msg, length: MemoryLayout.size(ofValue: msg))
        self.send(peripheralForUUIDString(uuidString), data: data)
    }
    
    func send(_ uuidString:String, message : UInt8, data : [UInt8]) {
        var bytes : [UInt8] = []
        bytes.append(message)
        if data.count > 0 {
            bytes.append(contentsOf: data)
        }
        let data = NSData.init(bytes: bytes, length: MemoryLayout.size(ofValue: bytes))
        self.send(peripheralForUUIDString(uuidString), data: data)
    }

    
    private func send(_ peripheral:CBPeripheral?, data : NSData) {
        guard let peripheral = peripheral, peripheral.services != nil else { return }
        
        let serviceUUID = CBUUID.init(string: "2220")
        let characteristicUUID = CBUUID.init(string: "2222")
        
        if let service = peripheral.services!.first(where: { $0.uuid.isEqual(serviceUUID) }),
            let characteristic = service.characteristics?.first(where: { $0.uuid.isEqual(characteristicUUID) }) {
            peripheral.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
        }
    }
}

// Communication with saved garments
protocol GarmentCommunicationDelegate {
    func didConnect(_ peripheralIdentifier:UUID)
    func didDisconnect(_ peripheralIdentifier:UUID)
    func garment(_ peripheralIdentifier:UUID, didReceive data:Data)
}
