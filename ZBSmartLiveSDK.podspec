

Pod::Spec.new do |s|
  s.name             = 'ZBSmartLiveSDK'
  s.version          = '0.4.51'
  s.summary          = 'ZBSmartLiveSDK for iOS,simple create live app.'

  s.homepage         = 'https://github.com/LipYoung/ZBSmartLiveSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LipYoung' => 'mainbundle@gmail.com' }
  s.source           = { :git => 'https://github.com/LipYoung/ZBSmartLiveSDK.git' , :tag => s.version }

  s.platform     = :ios
  s.requires_arc = true
  s.ios.deployment_target = '8.0'

  s.source_files = 'Pod/Library/include/ZBSmartLiveSDK/**/*','Pod/Library/include/ZBSmartLiveSDK/**/*.{c, h, m}'

  s.frameworks = ['UIKit', 'AVFoundation', 'CoreGraphics', 'CFNetwork', 'AudioToolbox', 'CoreMedia', 'VideoToolbox']
  s.dependency 'AFNetworking', '~> 3.0.4'
  s.dependency 'MJExtension', '~> 3.0.13'
  s.dependency 'SSZipArchive', '~> 1.6.2'
  s.dependency 'PLMediaStreamingKit', '~> 2.1.3'

  s.libraries = 'z', 'c++', 'resolv', 'icucore', 'sqlite3'

#  s.default_subspec = "precompiled"

#  s.subspec "precompiled" do |ss|
#    ss.vendored_libraries   = 'Pod/Library/lib/*.a'
#  end
end
