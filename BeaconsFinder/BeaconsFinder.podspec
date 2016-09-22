Pod::Spec.new do |s|
 
  s.name         = 'BeaconsFinder'
  s.version      = '0.1'
  s.summary      = 'Beacons Finder'
  s.homepage     = 'https://github.com/christosbimpas/BeaconsFinder'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { 'Christos Bimpas' => 'christosbimpas@gmail.com' }
  s.platform     = :ios, '9.0'
  s.source       = { :git => 'https://github.com/christosbimpas/BeaconsFinder.git', :tag => s.version }
  s.source_files  = 'BeaconsFinder/BeaconsFinder/*.swift'
 
end
