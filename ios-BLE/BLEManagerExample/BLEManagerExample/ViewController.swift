//
//  ViewController.swift
//  BLEManagerExample
//
//  Created by Christos Bimpas on 23/09/2016.
//  Copyright © 2016 Snepo. All rights reserved.
//

import UIKit
import BLEManager

class ViewController: UIViewController {

    @IBOutlet weak var tryButton: UIButton!
    @IBOutlet weak var rePairButton: UIButton!
    
    var wxPeripheral: WXPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        tryButton.isEnabled = false
        BLEManager.sharedInstance.delegate = self
        BLEManager.sharedInstance.initWithAdvertisingNames(names: ["fan jersey [R]","fan jersey [L]"])
        BLEManager.sharedInstance.startScanning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapOnButton(_ sender: AnyObject) {
        if (sender as! NSObject == tryButton) {
            var parameter = NSInteger(1)
            let data = NSData(bytes: &parameter, length: 1)
//            if let peripheral = wxPeripheral {
//                BLEManager.sharedInstance.sendDataToPeripheral(data: data, wxPeripheral: peripheral)
//                return
//            }
            BLEManager.sharedInstance.sendData(data: data)
        } else {
            tryButton.isEnabled = false
            BLEManager.sharedInstance.clearPairing()
            BLEManager.sharedInstance.startScanning()
        }
        
    }
}

// MARK: - BLEManagerDelegate

extension ViewController: BLEManagerDelegate {
    func BluetoothDidConnect() {
        print("BluetoothDidConnect")
        tryButton.isEnabled = true
        wxPeripheral = BLEManager.sharedInstance.peripheralsArray().last
        for peripheral in BLEManager.sharedInstance.peripheralsArray() {
            print(peripheral.peripheral)
        }
    }
    
    func BluetoothIsSearching() {
        print("BluetoothIsSearching")
    }
    func BluetoothEnabled() {
        print("BluetoothEnabled")
    }
    
    func BluetoothDisabled() {
        print("BluetoothDisabled")
    }
}

