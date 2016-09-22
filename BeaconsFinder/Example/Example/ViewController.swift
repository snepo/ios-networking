//
//  ViewController.swift
//  Example
//
//  Created by Christos Bimpas on 22/09/2016.
//  Copyright © 2016 Snepo. All rights reserved.
//

import UIKit
import BeaconsFinder

class ViewController: UIViewController {

    var _beacons = [Beacon]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        BeaconsFinder.sharedInstance.delegate = self
        BeaconsFinder.sharedInstance.authorization = BFAuthorization.Always
        BeaconsFinder.sharedInstance.initWithUUID(uuid: "CD1C7365-06C4-4E30-B90D-026B1289AA25")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - BeaconsFinderDelegate

extension ViewController: BeaconsFinderDelegate {
    
    public func didFindBeacons() {
     print("did find beacons")
        _beacons = BeaconsFinder.sharedInstance.beacons()!
        for beacon in _beacons {
            print(beacon.minor, beacon.uuid)
        }
    }
}

