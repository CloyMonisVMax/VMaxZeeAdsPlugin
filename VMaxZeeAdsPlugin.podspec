Pod::Spec.new do |s|

  s.name             = 'VMaxZeeAdsPlugin'
  s.version          = '0.1.17'
  s.summary          = 'VMaxZeeAdsPlugin integrates VMaxAdsSDK to show instream ads'
  s.description      = 'VMaxZeeAdsPlugin has currently integtared Instream Video Ads with companion banner ads.'
  s.homepage         = 'https://github.com/CloyMonisVMax/VMaxZeeAdsPlugin'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'CloyMonisVMax' => 'cloy.m@vserv.com' }
  s.source           = { :git => 'https://github.com/CloyMonisVMax/VMaxZeeAdsPlugin.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.swift_version = '5'
  s.source_files = 'VMaxZeeAdsPlugin/Classes/**/*'
  s.dependency 'VMaxAdsSDK'
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386' }
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386' }
  s.resource_bundles = {
      'VMaxZeeAdsPlugin' => ['VMaxZeeAdsPlugin/**']
  }
  s.resources = "VMaxZeeAdsPlugin/**/*.{png,json,xcassets,imageset,json}"
  
end
