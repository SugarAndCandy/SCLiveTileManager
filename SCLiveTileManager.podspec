Pod::Spec.new do |s|
  s.name     = 'SCLiveTileManager.podspec'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'simple live tile manager'
  s.homepage = 'http://gitlab.sugarandcandy.ru/iOS/SugarKit'
  s.social_media_url = 'https://twitter.com/sugarandcandyru'
  s.authors  = { 'Sugar and Candy' => 'hi@sugarandcandy.ru' }
  s.source   = { :git => 'https://github.com/SugarAndCandy/SCYandexDisk.git', :tag => s.version, :submodules => true }
  s.requires_arc = true
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"

  s.public_header_files = 'Core/**/*.h'
  s.source_files = 'Core/**/*.{m,h}'
end
