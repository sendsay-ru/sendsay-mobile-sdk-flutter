#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sendsay.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sendsay'
  s.version          = '0.1.0'
  s.summary          = 'Native SendsaySDK iOs Library.'
  s.description      = <<-DESC
  Плагин, который бриджит Dart к нативным SDK.
                       DESC
  s.homepage         = 'https://github.com/sendsay-ru/sendsay-mobile-sdk-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Sendsay' => 'ask@sendsay.ru' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'SendsaySDK', '0.1.0'
  s.dependency 'AnyCodable-FlightSchool', '0.6.3'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

end
