#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint testsdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'CustomerGlu'
  s.version          = '1.0.3'
  s.summary          = 'CustomerGlu '
  s.description      = <<-DESC



A new CustomerGlu.
                       DESC
  s.homepage         = 'https://github.com/customerglu/CG-iOS-SDK'
# s.license          = { :type => ‘MIT’, :file => ‘LICENSE.md’ }
  s.author           = { 'CustomerGlu' => 'hitesh.landge@customerglu.net' }
  s.source           = { :git => 'https://github.com/customerglu/CG-iOS-SDK.git', :tag => s.version.to_s }
  s.source_files = 'Sources/**/*.*'
  s.exclude_files = 'Tests/**/*.*'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  # s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
end
