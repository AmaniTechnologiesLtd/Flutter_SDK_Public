#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint amanisdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'amanisdk'
  s.version          = '0.0.11'
  s.summary          = 'Flutter bindings for our native sdks'
  s.description      = <<-DESC
  Amani Ai SDK Flutter bindings.
                       DESC
  s.homepage         = 'https://amani.ai'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'hi@amani.ai' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Amani'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
