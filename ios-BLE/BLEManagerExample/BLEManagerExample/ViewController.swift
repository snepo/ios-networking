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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tryButton.isEnabled = false
        BLEManager.sharedInstance.delegate = self
        BLEManager.sharedInstance.initWithAdvertisedName(name: "fan jersey [L]")
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

