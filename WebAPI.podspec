Pod::Spec.new do |s|
  s.name         = "WebAPI"
  s.version      = "1.0.14"
  s.summary      = "Swift client and tests for accessing various APIs around the web"
  s.description  = "Swift client and tests for accessing various APIs around the web."

  s.homepage     = "https://github.com/shvets/WebAPI"
  s.authors = { "Alexander Shvets" => "alexander.shvets@gmail.com" }
  s.license      = "MIT"
  s.source = { :git => 'https://github.com/shvets/WebAPI.git', :tag => s.version }

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "10.0"
  #s.watchos.deployment_target = "2.0"

  #s.requires_arc = true
  #s.ios.source_files = "Sources/**/*.swift"
  #s.tvos.source_files = "Sources/**/*.swift"
  #s.osx.source_files = "Sources/**/*.swift"
  # s.ios.source_files = 'Source/{iOS,Shared}/**/*'
   s.resource_bundles = {
    'com.rubikon.WebAPI' => ['Sources/**/*.js']
  }

  s.source_files = "Sources/**/*.swift"

  s.dependency 'Alamofire', '~> 4.7.3'
  s.dependency 'RxSwift', '~> 4.3.1'
  s.dependency 'SwiftyJSON', '~> 4.1.0'
  s.dependency 'SwiftSoup', '~> 1.7.4'
  s.dependency 'Files', '~> 2.0.1'
  s.dependency 'ConfigFile', '~> 1.1.0'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }
end
