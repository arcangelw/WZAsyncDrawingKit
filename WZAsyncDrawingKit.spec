Pod::Spec.new do |spec|
  spec.name = "WZAsyncDrawingKit"
  spec.version = "0.0.1"
  spec.license = ""
  spec.summary = "WZAsyncDrawingKit"

  spec.description = <<-DESC
WZAsyncDrawingKit
                   DESC
  spec.source = { :git => "https://github.com/arcangelw/WZAsyncDrawingKit.git", :tag => "v#{spec.version}" }
  spec.homepage = "https://github.com/arcangelw/WZAsyncDrawingKit"
  spec.authors = { "WU ZHE" => "wuzhezmc@gmail.com" }
  spec.social_media_url = "https://github.com/arcangelw"
  spec.swift_version = "5.8"
  spec.ios.deployment_target = '13.0'
  spec.frameworks = 'UIKit', 'Foundation'
  spec.source_files = "Sources/**/*.{swift,h,m}"
  spec.private_header_files = 'Sources/Proxy/include/*.h'
end

