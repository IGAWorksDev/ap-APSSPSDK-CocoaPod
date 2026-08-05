Pod::Spec.new do |s|
  s.name         = "APSSPMediationAppLovinMax"
  s.version      = "13.6.3.2"
  s.summary      = "APSSPSDK Mediation AppLovinMax Adapter"
  s.homepage     = "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod"
  s.license      = { "type": "Apache License, Version 2.0", "file": "LICENSE" }
  s.author       = { "mick.kim" => "mick.kim@adpopcorn.com", "odin.song" => "odin.song@adpopcorn.com" }

  s.ios.deployment_target = "13.0"
  s.source       = { :git => "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod.git", :tag => "3.3.0-release1" }

  s.source_files = "AppLovinMax/Sources/**/*.swift"

  s.requires_arc = true
  s.swift_versions = ["5.0"]
  s.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }

  s.dependency "APSSPSDK", ">= 3.2.2"
  s.dependency "AppLovinSDK", ">= 12.0"
end
