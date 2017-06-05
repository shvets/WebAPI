Pod::Spec.new do |s|
  s.name         = "WebAPI"
  s.version      = "1.0.7"
  s.summary      = "Swift client and tests for accessing various APIs around the web"
  s.description  = "Swift client and tests for accessing various APIs around the web."

  s.homepage     = "https://github.com/shvets/WebAPI"
  s.authors = { "Alexander Shvets" => "alexander.shvets@gmail.com" }
  s.license      = "MIT"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3' }

  s.ios.deployment_target = "10.0"
  #s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "10.0"
  #s.watchos.deployment_target = "2.0"

  s.source = { :git => 'https://github.com/shvets/WebAPI.git', :tag => s.version }
  s.source_files = "Sources/**/*.swift"

  s.dependency 'Alamofire', '~> 4.4.0'
  s.dependency 'AlamofireImage', '~> 3.2.0'
  s.dependency 'SwiftyJSON', '~> 3.1.4'
  s.dependency 'SwiftSoup', '~> 1.3.2'
  s.dependency 'Wrap', '~> 2.1.0'
  s.dependency 'Unbox', '~> 2.4.0'
end
