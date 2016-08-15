

Pod::Spec.new do |s|
  s.name             = 'ZBSmartLiveSDK'
  s.version          = '0.2.3'
  s.summary          = 'ZBSmartLiveSDK for iOS,simple create live app.'

  s.homepage         = 'https://github.com/LipYoung/ZBSmartLiveSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LipYoung' => 'mainbundle@gmail.com' }
  s.source           = { :git => 'https://github.com/LipYoung/ZBSmartLiveSDK.git' , :tag => s.version }

  s.platform     = :ios
  s.requires_arc = true
  s.ios.deployment_target = '8.0'

  s.public_header_files = 'Pod/Library/include/ZBSmartLiveSDK/*.h'
  s.source_files = 'Pod/Library/include/ZBSmartLiveSDK/*.h'

  s.frameworks = ['UIKit', 'AVFoundation', 'CoreGraphics', 'CFNetwork', 'AudioToolbox', 'CoreMedia', 'VideoToolbox']
  s.dependency 'PLCameraStreamingKit', '~> 1.8.1'
  s.dependency 'AFNetworking', '~> 3.0.4'
  s.dependency 'MJExtension', '~> 3.0.11'
  s.libraries = 'z', 'c++'

  s.default_subspec = "precompiled"

  s.subspec "precompiled" do |ss|
    ss.vendored_libraries   = 'Pod/Library/lib/*.a'
  end
end
