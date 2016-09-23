Pod::Spec.new do |s|
 
  s.name         = 'BLEManager'
  s.version      = '0.1'
  s.summary      = 'BLE Manager'
  s.homepage     = 'https://github.com/snepo/ios-pods'
  s.license      = { :type => 'MIT', :file => 'ios-BLE/LICENSE' }
  s.author             = { 'Christos Bimpas' => 'christosbimpas@gmail.com' }
  s.platform     = :ios, '9.0'
  s.source       = { :git => 'https://github.com/christosbimpas/BLEManager.git' }
  s.source_files  = 'ios-BLE/BLEManager/*.swift'
 
end
