Pod::Spec.new do |s|
 
  s.name         = 'ios-garment-manager'
  s.version      = '1.0'
  s.summary      = 'Garment Manager'
  s.homepage     = 'https://github.com/snepo/ios-pods'
  s.license      = { :type => 'MIT', :file => 'ios-garment/LICENSE' }
  s.author             = { 'Christos Bimpas' => 'christosbimpas@gmail.com' }
  s.platform     = :ios, '10.0'
  s.source       = { :git => 'https://github.com/snepo/ios-pods.git' }
  s.source_files = 'ios-garment/GarmentManager/*.swift'
 
end
