use_frameworks!

target 'WebAPI_iOS' do
  platform :ios, '10.0'

  podspec :path => 'WebAPI.podspec'

  dependencies

  target 'WebAPI_iOSTests' do
    inherit! :search_paths
  end

end

target 'WebAPI_tvOS' do
  platform :tvos, '10.10'

  dependencies

  podspec :path => 'WebAPI.podspec'

  target 'WebAPI_tvOSTests' do
    inherit! :search_paths
  end
end

target 'WebAPI_macOS' do
  platform :macos, '10.10'

  dependencies

  podspec :path => 'WebAPI.podspec'

  target 'WebAPI_macOSTests' do
    inherit! :search_paths
  end
end

def dependencies
  pod 'Alamofire', '4.4.0'
  pod 'AlamofireImage', '~> 3.2.0'
  pod 'SwiftyJSON', '3.1.4'
  pod 'SwiftSoup', '~> 1.3.2'
  pod 'Wrap', '2.1.0'
  pod 'Unbox', '~> 2.4.0'
end
