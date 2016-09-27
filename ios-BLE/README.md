# BLEManager
podfile

        use_frameworks!

        target <YOUR_TARGET_NAME> do
        pod 'BLEManager', :podspec => 'https://raw.githubusercontent.com/snepo/ios-pods/master/ios-BLE/BLEManager.podspec'
        end

initialize

        BLEManager.sharedInstance.delegate = self
        BLEManager.sharedInstance.advertisingNames = ["fan jersey [R]","fan jersey [L]"] // this is optional, if advertisingNames not set, the manager will store all peripherals discovered
        BLEManager.sharedInstance.initialise()
        BLEManager.sharedInstance.startScanning()
        
send data

        var parameter = NSInteger(1)
        let data = NSData(bytes: &parameter, length: 1)
        BLEManager.sharedInstance.sendData(data: data) // send data to all stored peripherals
        
         BLEManager.sharedInstance.sendDataToPeripheral(data: data, wxPeripheral: wxPeripheral) // send data to a specific peripheral
    
    
reset

                BLEManager.sharedInstance.clearPairing()
                BLEManager.sharedInstance.startScanning()
     
     
delegate

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
