Pod::Spec.new do |s|
  s.name         = "APSSPSDK"
  s.version      = "3.0.0"
  s.summary      = "AdPopcorn SSP iOS SDK (Swift)"
  s.homepage     = "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod"
  s.license      = { "type": "Apache License, Version 2.0", "file": "LICENSE" }
  s.author       = { "mick.kim" => "mick.kim@adpopcorn.com", "odin.song" => "odin.song@adpopcorn.com" }

  s.ios.deployment_target = "13.0"
  s.source       = { :git => "https://github.com/IGAWorksDev/ap-APSSPSDK-CocoaPod.git", :tag => "3.0.0" }

  s.vendored_frameworks = "APSSPSDK/APSSPSDK.xcframework"

  s.frameworks = "UIKit", "Foundation", "QuartzCore", "AdSupport", "AVFoundation", "AVKit",
                 "MobileCoreServices", "SystemConfiguration", "WebKit", "CoreLocation", "AppTrackingTransparency"

  s.requires_arc = true
  s.swift_versions = ["5.0"]
  s.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }
end
