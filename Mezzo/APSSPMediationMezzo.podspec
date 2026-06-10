Pod::Spec.new do |s|
  s.name         = "APSSPMediationMezzo"
  s.version      = "1.0.7"
  s.summary      = "APSSPSDK Mediation MezzoMedia Adapter"
  s.homepage     = "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod"
  s.license      = { "type": "Apache License, Version 2.0", "file": "LICENSE" }
  s.author       = { "mick.kim" => "mick.kim@adpopcorn.com", "odin.song" => "odin.song@adpopcorn.com" }

  s.ios.deployment_target = "13.0"
  s.source       = { :git => "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod.git", :tag => "3.1.6" }

  s.source_files = "Mezzo/Sources/**/*.swift"
  s.vendored_frameworks = "Mezzo/Lib/LibADPlus.xcframework", "Mezzo/Lib/OMSDK_Cjnet.xcframework"

  s.requires_arc = true
  s.swift_versions = ["5.0"]
  s.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }

  s.dependency "APSSPSDK", ">= 3.1.6"
end
