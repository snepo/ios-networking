Pod::Spec.new do |s|
 
  s.name         = 'BLEManager'
  s.version      = '0.1'
  s.summary      = 'BLE Manager'
  s.homepage     = 'https://github.com/christosbimpas/BLEManager'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { 'Christos Bimpas' => 'christosbimpas@gmail.com' }
  s.platform     = :ios, '9.0'
  s.source       = { :git => 'https://github.com/christosbimpas/BLEManager.git', :tag => s.version }
  s.source_files  = 'BLEManager/*.swift'
 
end
