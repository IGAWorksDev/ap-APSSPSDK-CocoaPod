Pod::Spec.new do |s|
  s.name         = "APSSPMediationGAM"
  s.version      = "13.5.0.2"
  s.summary      = "APSSPSDK Mediation GAM Adapter"
  s.homepage     = "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod"
  s.license      = { "type": "Apache License, Version 2.0", "file": "LICENSE" }
  s.author       = { "mick.kim" => "mick.kim@adpopcorn.com", "odin.song" => "odin.song@adpopcorn.com" }

  s.ios.deployment_target = "13.0"
  s.source       = { :git => "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod.git", :tag => "3.3.0-release1" }

  s.source_files = "GAM/Sources/**/*.swift"

  s.requires_arc = true
  s.static_framework = true
  s.swift_versions = ["5.0"]
  s.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }

  s.dependency "APSSPSDK", ">= 3.2.2"
  s.dependency "Google-Mobile-Ads-SDK", ">= 11.0"
end
