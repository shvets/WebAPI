use_frameworks!

def project_dependencies
  pod 'Alamofire', '~> 4.4.0'
  pod 'AlamofireImage', '~> 3.2.0'
  pod 'SwiftyJSON', '~> 3.1.4'
  pod 'SwiftSoup', '~> 1.3.2'
  pod 'Wrap', '2.1.0'
  pod 'Unbox', '~> 2.4.0'
end

target 'WebAPI_iOS' do
  platform :ios, '10.0'

  podspec :path => 'WebAPI.podspec'

  project_dependencies

  target 'WebAPI_iOSTests' do
    inherit! :search_paths
  end

end

target 'WebAPI_tvOS' do
  platform :tvos, '10.10'

  project_dependencies

  podspec :path => 'WebAPI.podspec'

  target 'WebAPI_tvOSTests' do
    inherit! :search_paths
  end
end

target 'WebAPI_macOS' do
  platform :osx, '10.10'

  project_dependencies

  podspec :path => 'WebAPI.podspec'

  target 'WebAPI_macOSTests' do
    inherit! :search_paths
  end
end

