//
//  OutfitManager+Commands.swift
//  nadix
//
//  Created by james on 3/4/17.
//  Copyright © 2017 Snepo. All rights reserved.
//

import Foundation

enum GarmentCommands : UInt8 {
    case requestFirmwareVersion = 1
    case initiateFirmwareUpdate = 2
    case requestBatteryStatus = 3
    case resetI2CBus = 4
    case toggleAccelerometers = 10
    case setSampleRate = 11
    case setSensitivity = 12
    case requestCalibration = 13
    case toggleCalibration = 14
    case setMotorSpeed = 19
    case setAllMotorSpeeds = 20
    case stopAllMotors = 21
}

//high-level commands
extension OutfitManager {
    static let timeBetweenVibrations = 0.5
    static let kActiveGarment = "kActiveGarment"
    static let kMotorIndex = "kMotorIndex"
    
    func vibrateSequence(_ activeGarment:ActiveGarment, fromIndex:Int = 0) {
        Timer.scheduledTimer(timeInterval: OutfitManager.timeBetweenVibrations,
                             target: self,
                             selector: #selector(playNext),
                             userInfo: NSDictionary(dictionary:[OutfitManager.kActiveGarment : activeGarment,
                                                                OutfitManager.kMotorIndex : fromIndex]),
                             repeats: false)
    }
    
    @objc fileprivate func playNext(_ timer:Timer) {
        guard let userInfo = timer.userInfo as? NSDictionary,
            let activeGarment = userInfo.object(forKey: OutfitManager.kActiveGarment) as? ActiveGarment,
            let motorIndex = userInfo.object(forKey: OutfitManager.kMotorIndex) as? Int else { return }
        switch activeGarment.garmentType {
        case .pants:
            if let section = PantsSection(rawValue: motorIndex) {
                vibratePants(activeGarment, section: section)
                vibrateSequence(activeGarment, fromIndex:motorIndex+1)
            }
            else {
                stopMotors(activeGarment)
            }
        default:
            return
        }
    }
}

//low-level commands
extension OutfitManager {

    func resetI2C(_ activeGarment:ActiveGarment) {
        guard let uuidString = activeGarment.garment?.uuid else { return }
        GarmentManager.sharedManager.send(uuidString, message: GarmentCommands.resetI2CBus.rawValue)
    }

    func stopMotors(_ activeGarment:ActiveGarment) {
        guard let uuidString = activeGarment.garment?.uuid else { return }
        GarmentManager.sharedManager.send(uuidString, message: GarmentCommands.stopAllMotors.rawValue)
    }
    
    func vibratePants(_ activeGarment:ActiveGarment, section:PantsSection) {
        guard activeGarment.garmentType == .pants else { return }
        vibrate(activeGarment, index:section.rawValue, isMotorB: false, motorValue: 0xF0, duration: 0.3)
        vibrate(activeGarment, index:section.rawValue, isMotorB: true, motorValue: 0xF0, duration: 0.3)
    }
    
    func vibrate(_ activeGarment:ActiveGarment, index:Int, isMotorB:Bool, motorValue:UInt8, duration:TimeInterval) {
        let loops = UInt8(duration * 100) //duration in seconds, firmware 10ms / loop. So x100 to determine loops / second.
        guard let uuidString = activeGarment.garment?.uuid else { return }
        //print("vibrating index \(index)\(isMotorB ? "B":"A"), (\(loops) x0.1)")
        var driverNumber = Int8(index + 1)
        if isMotorB { driverNumber = -driverNumber }
        let data: [UInt8] = [UInt8(bitPattern:driverNumber), motorValue & 0xF0, loops] //currently not used in fw
        GarmentManager.sharedManager.send(uuidString,message: GarmentCommands.setMotorSpeed.rawValue, data: data)
        
//        var count = 0
//        switch activeGarment.garmentType {
//        case .pants:
//            count = PantsSection.allSections.count
//        case .top:
//            count = TopSection.allSections.count
//        default:
//            return
//        }
//        var songArray = Array(repeating: UInt8(0), count: count)
        
    }
    

}
