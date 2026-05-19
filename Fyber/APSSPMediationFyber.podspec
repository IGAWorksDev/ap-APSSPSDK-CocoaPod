Pod::Spec.new do |s|
  s.name         = "APSSPMediationFyber"
  s.version      = "8.4.6.0"
  s.summary      = "APSSPSDK Mediation Fyber Adapter"
  s.homepage     = "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod"
  s.license      = { "type": "Apache License, Version 2.0", "file": "LICENSE" }
  s.author       = { "mick.kim" => "mick.kim@adpopcorn.com", "odin.song" => "odin.song@adpopcorn.com" }

  s.ios.deployment_target = "13.0"
  s.source       = { :git => "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod.git", :tag => "release_3_0_0" }

  s.vendored_frameworks = "Fyber/APSSPMediationFyber.xcframework"

  s.requires_arc = true
  s.static_framework = true
  s.swift_versions = ["5.0"]
  s.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }

  s.dependency "APSSPSDK", ">= 3.0.0"
  s.dependency "Fyber_Marketplace_SDK", "~> 8.4"
end
