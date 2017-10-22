Pod::Spec.new do |s|
  s.name         = "WebAPI"
  s.version      = "1.0.11"
  s.summary      = "Swift client and tests for accessing various APIs around the web"
  s.description  = "Swift client and tests for accessing various APIs around the web."

  s.homepage     = "https://github.com/shvets/WebAPI"
  s.authors = { "Alexander Shvets" => "alexander.shvets@gmail.com" }
  s.license      = "MIT"
  s.source = { :git => 'https://github.com/shvets/WebAPI.git', :tag => s.version }

  s.ios.deployment_target = "10.0"
  #s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "10.0"
  #s.watchos.deployment_target = "2.0"

  #s.requires_arc = true
  #s.ios.source_files = "Sources/**/*.swift"
  #s.tvos.source_files = "Sources/**/*.swift"
  #s.osx.source_files = "Sources/**/*.swift"
  # s.ios.source_files = 'Source/{iOS,Shared}/**/*'

  s.source_files = "Sources/**/*.swift"

  s.dependency 'Alamofire', '~> 4.5.1'
  #s.dependency 'AlamofireImage', '~> 3.2.0'
  s.dependency 'SwiftyJSON', '~> 3.1.4'
  s.dependency 'SwiftSoup', '~> 1.5.5'
  s.dependency 'Files', '~> 1.9.0'
  s.dependency 'ConfigFile', '~> 1.0.0'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }
end
