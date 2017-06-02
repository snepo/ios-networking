//
//  OutfitManager.swift
//  nadix
//
//  Created by james on 23/3/17.
//  Copyright © 2017 Snepo. All rights reserved.
//

import Foundation

//MARK: - GarmentCommunicationDelegate

extension OutfitManager : GarmentCommunicationDelegate {
    
    func didConnect(_ peripheralIdentifier:UUID) {
        //connected to saved peripheral
        guard let garment = Garment.mr_findFirst(byAttribute: "uuid", withValue: peripheralIdentifier.uuidString) else { return }
        let activeGarment = ActiveGarment(garment)
        activeGarment.delegate = self
        currentOutfit[peripheralIdentifier] = activeGarment
        if let garmentType = activeGarmentType(garment) {
            lastKnownTypes[garment] = garmentType
        }
        notify(activeGarment, name:Constants.NotificationKey.garmentDidConnect)
    }
    
    func didDisconnect(_ peripheralIdentifier:UUID) {
        guard let activeGarment = currentOutfit[peripheralIdentifier] else { return }
        notify(activeGarment, name:Constants.NotificationKey.garmentDidDisconnect)
        currentOutfit.removeValue(forKey: peripheralIdentifier)
    }
    
    func garment(_ peripheralIdentifier:UUID, didReceive data:Data) {
        guard let garment = currentOutfit[peripheralIdentifier] else { return }
        garment.didReceive(data)
    }
}

extension OutfitManager : ActiveGarmentDelegate {
    func activeGarment(_ activeGarment: ActiveGarment, didChangeType type: GarmentType) {
        print("\(activeGarment.garment?.uuid) didChangeState to \(type)")
        switch type {
        case .unknown: //connected with unknown type
            notify(activeGarment, name:Constants.NotificationKey.garmentDidError)
        case .pants:
            NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
            if let g = activeGarment.garment {
                lastKnownTypes[g] = type
            }
            notify(activeGarment, name:Constants.NotificationKey.garmentDidConnect)
        }
    }
}

//MARK: - Notifications
extension OutfitManager {
    func notify(_ garment:ActiveGarment, name:String) {
        NotificationCenter.default.post(name: Notification.Name(name), object: self, userInfo: ["garment":garment])
    }
}

//MARK: - Class
class OutfitManager : NSObject {
    static let sharedManager: OutfitManager = OutfitManager()
    static let garmentTypeInterval: TimeInterval = 3.0
    
    var currentOutfit: [UUID:ActiveGarment] = [:]
    var lastKnownTypes: [Garment:GarmentType] = [:]

    override private init() {
        super.init()
        GarmentManager.sharedManager.delegate = self
        let connectedUUIDs = GarmentManager.sharedManager.connectedPeripherals.values.map({ $0.identifier })
        _ = connectedUUIDs.map({ self.didConnect($0) })
        
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: OutfitManager.garmentTypeInterval, repeats: true) { _ in
                self.checkAllTypes()
            }
        } else {
            Timer.scheduledTimer(timeInterval: OutfitManager.garmentTypeInterval, target: self, selector: #selector(checkAllTypes), userInfo: nil, repeats: true)
        }

    }
    
    func currentGarments() -> [ActiveGarment] {
        return Array(currentOutfit.values)
    }
    
    func currentGarment() -> ActiveGarment? {
        
        return currentGarments().first
    }
    
    func checkAllTypes() {
        let activeGarments = Array(self.currentOutfit.values) as [ActiveGarment]
        _ = activeGarments.map({ $0.updateGarmentType() })
        _ = activeGarments.filter({ $0.garmentType == .unknown }).map({ self.resetI2C($0) })
    }
    
    func activeGarmentType(_ garment:Garment) -> GarmentType? {
        if let garmentType = GarmentType(rawValue: garment.type),
            garmentType != .unknown {
            return garmentType
        }
        return nil
    }
    
    func hasConnectedOutfits() -> Bool {
        return currentGarments().count > 0
    }
    
    func reset() {
        currentOutfit = [:]
        lastKnownTypes = [:]
    }
    

}
