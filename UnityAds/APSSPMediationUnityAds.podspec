Pod::Spec.new do |s|
  s.name         = "APSSPMediationUnityAds"
  s.version      = "4.17.0.13"
  s.summary      = "APSSPSDK Mediation UnityAds Adapter"
  s.homepage     = "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod"
  s.license      = { "type": "Apache License, Version 2.0", "file": "LICENSE" }
  s.author       = { "mick.kim" => "mick.kim@adpopcorn.com", "odin.song" => "odin.song@adpopcorn.com" }

  s.ios.deployment_target = "13.0"
  s.source       = { :git => "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod.git", :tag => "3.4.0" }

  s.source_files = "UnityAds/Sources/**/*.swift"

  s.requires_arc = true
  s.static_framework = true
  s.swift_versions = ["5.0"]
  s.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }

  s.dependency "APSSPSDK", ">= 3.4.0"
  s.dependency "UnityAds", ">= 4.0"
end
