Pod::Spec.new do |s|
  s.name         = "APSSPMediationAdFit"
  s.version      = "3.18.3.8"
  s.summary      = "APSSPSDK Mediation AdFit Adapter"
  s.homepage     = "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod"
  s.license      = { "type": "Apache License, Version 2.0", "file": "LICENSE" }
  s.author       = { "mick.kim" => "mick.kim@adpopcorn.com", "odin.song" => "odin.song@adpopcorn.com" }

  s.ios.deployment_target = "14.0"
  s.source       = { :git => "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod.git", :tag => "3.1.7" }

  s.source_files = "AdFit/Sources/**/*.swift"

  s.requires_arc = true
  s.swift_versions = ["5.0"]
  s.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }

  s.dependency "APSSPSDK", ">= 3.1.7"
  s.dependency "AdFitSDK", "~> 3.18"
end
