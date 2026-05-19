Pod::Spec.new do |s|
  s.name         = "APSSPMediationFluct"
  s.version      = "6.42.1.2"
  s.summary      = "APSSPSDK Mediation Fluct Adapter"
  s.homepage     = "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod"
  s.license      = { "type": "Apache License, Version 2.0", "file": "LICENSE" }
  s.author       = { "mick.kim" => "mick.kim@adpopcorn.com", "odin.song" => "odin.song@adpopcorn.com" }

  s.ios.deployment_target = "13.0"
  s.source       = { :git => "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod.git", :tag => "3.0.2" }

  s.vendored_frameworks = "Fluct/APSSPMediationFluct.xcframework"

  s.requires_arc = true
  s.static_framework = true
  s.swift_versions = ["5.0"]
  s.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }

  s.dependency "APSSPSDK", ">= 3.0.2"
  s.dependency "FluctSDK", "~> 6.42"
end
