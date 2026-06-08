Pod::Spec.new do |s|
  s.name         = "APSSPMediationVungle"
  s.version      = "7.7.2.6"
  s.summary      = "APSSPSDK Mediation Vungle Adapter"
  s.homepage     = "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod"
  s.license      = { "type": "Apache License, Version 2.0", "file": "LICENSE" }
  s.author       = { "mick.kim" => "mick.kim@adpopcorn.com", "odin.song" => "odin.song@adpopcorn.com" }

  s.ios.deployment_target = "13.0"
  s.source       = { :git => "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod.git", :tag => "3.1.2" }

  s.source_files = "Vungle/Sources/**/*.swift"

  s.requires_arc = true
  s.swift_versions = ["5.0"]
  s.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }

  s.dependency "APSSPSDK", ">= 3.1.2"
  s.dependency "VungleAds", "~> 7.7.2"
end
