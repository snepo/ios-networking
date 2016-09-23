# BLEManager
podfile

use_frameworks!

        target <YOUR_TARGET_NAME> do
        pod 'BLEManager', :podspec => 'https://raw.githubusercontent.com/snepo/ios-pods/master/ios-BLE/BLEManager.podspec'
        end


examples

initialize
        BLEManager.sharedInstance.delegate = self
        BLEManager.sharedInstance.initWithAdvertisedName(name: "fan jersey [L]")
        BLEManager.sharedInstance.startScanning()
        
send data
            var parameter = NSInteger(1)
            let data = NSData(bytes: &parameter, length: 1)
            BLEManager.sharedInstance.sendData(data: data)
            
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
