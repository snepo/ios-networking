Pod::Spec.new do |s|
 
  s.name         = 'BeaconsFinder'
  s.version      = '0.1'
  s.summary      = 'Beacons Finder'
  s.homepage     = 'https://github.com/snepo/ios-pods'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { 'Christos Bimpas' => 'christosbimpas@gmail.com' }
  s.platform     = :ios, '9.0'
  s.source       = { :git => 'https://github.com/snepo/ios-pods.git', :tag => s.version }
  s.source_files  = 'ios-pods/master/BeaconsFinder/BeaconsFinder/*.swift'
 
end
