#
# Be sure to run `pod lib lint ZBSmartLiveSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZBSmartLiveSDK'
  s.version          = '0.1.7'
  s.summary          = 'ZBSmartLiveSDK for iOS,simple create live app.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
* Markdown format.
* Don't worry about the indent, we strip it!
                       DESC

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

  # s.resource_bundles = {
  #   'ZBSmartLiveSDK' => ['ZBSmartLiveSDK/Assets/*.png']
  # }

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
