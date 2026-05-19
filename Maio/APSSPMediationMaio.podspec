Pod::Spec.new do |s|
  s.name         = "APSSPMediationMaio"
  s.version      = "2.2.1.1"
  s.summary      = "APSSPSDK Mediation Maio Adapter"
  s.homepage     = "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod"
  s.license      = { "type": "Apache License, Version 2.0", "file": "LICENSE" }
  s.author       = { "mick.kim" => "mick.kim@adpopcorn.com", "odin.song" => "odin.song@adpopcorn.com" }

  s.ios.deployment_target = "15.0"
  s.source       = { :git => "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod.git", :tag => "3.0.2" }

  s.vendored_frameworks = "Maio/APSSPMediationMaio.xcframework"

  s.requires_arc = true
  s.static_framework = true
  s.swift_versions = ["5.0"]
  s.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }

  s.dependency "APSSPSDK", ">= 3.0.2"
  s.dependency "MaioSDK-v2", "~> 2.2"
end
