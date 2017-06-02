//
//  ViewController.swift
//  BLEManagerExample
//
//  Created by Christos Bimpas on 23/09/2016.
//  Copyright © 2016 Snepo. All rights reserved.
//

import UIKit
import BLEManager

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tryButton: UIButton!
    @IBOutlet weak var rePairButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var wxPeripherals: [WXPeripheral] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        tryButton.isEnabled = false
        BLEManager.sharedInstance.delegate = self
        //BLEManager.sharedInstance.advertisingNames = ["fan jersey [R]","fan jersey [L]"]
        BLEManager.sharedInstance.connectToClosest = true
        BLEManager.sharedInstance.initialise()
        BLEManager.sharedInstance.startScanning()
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
    
    //MARK: - UITableViewDelegate
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        let wxPeripheral = wxPeripherals[indexPath.row]
        cell.textLabel!.text = wxPeripheral.name
        cell.detailTextLabel!.text = wxPeripheral.uuid
        if !wxPeripheral.connected {
            cell.textLabel?.textColor = UIColor.lightGray
            cell.detailTextLabel!.text = "not connected"
        }
        return cell;
    }
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wxPeripherals.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var parameter = NSInteger(1)
        let data = NSData(bytes: &parameter, length: 1)
        let wxPeripheral = wxPeripherals[indexPath.row]
        if !wxPeripheral.connected {
            let alert = UIAlertController(title: "Alert", message: "This peripheral is not connected", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            BLEManager.sharedInstance.sendDataToPeripheral(data: data, wxPeripheral: wxPeripheral)
        }
        
    }
}

// MARK: - BLEManagerDelegate

extension ViewController: BLEManagerDelegate {
    func BluetoothDidConnect() {
        print("BluetoothDidConnect")
        tryButton.isEnabled = true
        wxPeripherals = []
        wxPeripherals = BLEManager.sharedInstance.peripheralsArray()
        tableView.reloadData()
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

