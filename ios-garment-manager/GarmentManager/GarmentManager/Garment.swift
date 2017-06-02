//
//  Garment.swift
//  nadix
//
//  Created by james on 13/3/17.
//  Copyright © 2017 Snepo. All rights reserved.
//


import Foundation
import CoreData

enum GarmentType: Int16 {
    case unknown
    case pants
    static let allKnownTypes = [pants]
}

extension Garment {
    
    static func == (garment1: Garment, garment2: Garment) -> Bool {
        return garment1.uuid == garment2.uuid
    }

    var garmentType : GarmentType {
        if let result = GarmentType(rawValue:type) {
            return result
        }
        return .unknown
    }
}
