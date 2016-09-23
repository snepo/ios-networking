//
//  Beacon.swift
//  BeaconsFinder
//
//  Created by Christos Bimpas on 22/09/2016.
//  Copyright © 2016 Snepo. All rights reserved.
//

import Foundation

public class Beacon: NSObject {
    public let name: String
    public let uuid: String
    public let major: NSNumber
    public let minor: NSNumber
    
    init(name: String, uuid: String, major: NSNumber, minor: NSNumber) {
        self.name = name
        self.uuid = uuid
        self.major = major
        self.minor = minor
    }
}
