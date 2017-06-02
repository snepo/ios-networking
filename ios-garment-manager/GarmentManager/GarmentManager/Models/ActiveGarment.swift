//
//  ActiveGarment.swift
//  nadix
//
//  Created by james on 30/3/17.
//  Copyright © 2017 Snepo. All rights reserved.
//

import Foundation
import FocusMotion

protocol ActiveGarmentDelegate {
    func activeGarment(_ activeGarment:ActiveGarment, didChangeType type:GarmentType)
}


struct AccelerometerReading {
    var x: Int16
    var y: Int16
    var z: Int16
}

enum PantsSection : Int{
    case waist = 0
    case upperLeft = 1
    case upperRight = 2
    case lowerLeft = 3
    case lowerRight = 4
    static let allSections = [waist, upperLeft, upperRight, lowerLeft, lowerRight]
}
enum TopSection : Int {
    case middle = 0
    case left = 1
    case right = 2
    static let allSections = [middle, left, right]
}


enum GarmentTypeMaxIndex : Int {
    case top = 2
    case pants = 4
}

class ActiveGarment {
    var delegate : ActiveGarmentDelegate?
    
    var startDate:Date
    var fmDeviceOutput: FMDeviceOutput
    
    var garment : Garment?
    var garmentType : GarmentType {
        if let g = garment, let resolvedType = GarmentType(rawValue:g.type) {
            return resolvedType
        }
        return .unknown
    }
    var sensors: [Int8:AccelerometerReading] = [:]
    var (maxActiveIndex, maxIndexUpdate) : (Int8?, Date?)
    
    var isPlayingSong = false
    
    init(_ garment:Garment) {
        self.garment = garment
        garment.type = GarmentType.unknown.rawValue
        startDate = Date() //reset when garment type discovered
        fmDeviceOutput = FMDeviceOutput.init(numAccel: 5, numGyro: 0, numMag: 0)
    }
    
    func updateGarmentType() -> GarmentType {
        var garmentType:GarmentType = .unknown
        //if just lost sensor count
        if maxIndexUpdate != nil, // had a max update
            Date().timeIntervalSince(maxIndexUpdate!) > 2.0 { //was over 2s ago
            //reset max flags
            (maxActiveIndex, maxIndexUpdate) = (nil, nil)
            garmentType = .unknown
        } else if maxActiveIndex == Int8(GarmentTypeMaxIndex.pants.rawValue) {
            garmentType = .pants
        }
        //print("currentType: \(garment?.type), detectedType: \(garmentType.rawValue)")
        //check if changed
        if let g = garment, g.type != garmentType.rawValue {
            if garmentType != .unknown { //clear old sensor data
                fmDeviceOutput.clear()
                startDate = Date()
            }
            garment?.type = garmentType.rawValue
            delegate?.activeGarment(self, didChangeType: garmentType)
        }
        return garmentType
    }
}

