# BeaconsFinder

Add this to your app's info.plist:

<key>NSLocationWhenInUseUsageDescription</key>
	<string>$(PRODUCT_NAME) wants to use your location</string>

Framework use:

BeaconsFinder.sharedInstance.delegate = self
BeaconsFinder.sharedInstance.initWithUUID(uuid: "CD1C7365-06C4-4E30-B90D-026B1289AA25")

Add the delegate to your class:

// MARK: - BeaconsFinderDelegate

extension ViewController: BeaconsFinderDelegate {
    
    public func didFindBeacons() {
     print(BeaconsFinder.sharedInstance.beacons())
    }
}
