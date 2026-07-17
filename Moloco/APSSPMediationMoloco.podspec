Pod::Spec.new do |s|
  s.name         = "APSSPMediationMoloco"
  s.version      = "4.5.1.11"
  s.summary      = "APSSPSDK Mediation Moloco Adapter"
  s.homepage     = "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod"
  s.license      = { "type": "Apache License, Version 2.0", "file": "LICENSE" }
  s.author       = { "mick.kim" => "mick.kim@adpopcorn.com", "odin.song" => "odin.song@adpopcorn.com" }

  s.ios.deployment_target = "13.0"
  s.source       = { :git => "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod.git", :tag => "3.2.1" }

  s.source_files = "Moloco/Sources/**/*.swift"

  s.requires_arc = true
  s.swift_versions = ["5.0"]
  s.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }

  s.dependency "APSSPSDK", ">= 3.2.1"
  s.dependency "MolocoSDKiOS", ">= 4.0"
end
