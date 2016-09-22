//
//  BeaconsFinder.swift
//  BeaconsFinder
//
//  Created by Christos Bimpas on 22/09/2016.
//  Copyright © 2016 Snepo. All rights reserved.
//

import Foundation
import CoreLocation


public enum BFAuthorization {
    case Always
    case WhenInUse
}

public protocol BeaconsFinderDelegate {
    func didFindBeacons()
}

public class BeaconsFinder : NSObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    public static let sharedInstance = BeaconsFinder()
    public var delegate: BeaconsFinderDelegate?
    public var _uuid: String?
    public var authorization = BFAuthorization.WhenInUse
    var _beacons: [Beacon]? = []
    var locationManager: CLLocationManager!
    
    public func initWithUUID(uuid: String) {
        _uuid = uuid
        locationManager = CLLocationManager()
        locationManager.delegate = self
       
        switch authorization {
        case BFAuthorization.Always:
            locationManager.requestAlwaysAuthorization()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    public func startScanning() {
        print("Start scanning")
        let uuid = UUID(uuidString: _uuid!)!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "beacon")
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    public func stopScanning() {
        let uuid = UUID(uuidString: _uuid!)!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "beacon")
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
    
    public func beacons() -> [Beacon]? {
        return _beacons
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse || status == .authorizedAlways) {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        } else if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if status == .restricted {
            
        } else if status == .denied {
            
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            for beacon in beacons {
                var beaconExists = false
                for cachedBeacon in _beacons! {
                    if (cachedBeacon.minor == beacon.minor && cachedBeacon.major  == beacon.major) {
                        beaconExists = true
                        break
                    }
                }
                if !beaconExists {
                    let myBeacon = Beacon(name: "test", uuid: _uuid!, major: beacon.major, minor: beacon.minor)
                    _beacons?.append(myBeacon)
                }
            }
            self.delegate?.didFindBeacons()
        } else {
            print("no beacons found")
        }
    }
}
