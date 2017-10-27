source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/shvets/Specs.git'

use_frameworks!

def project_dependencies
  pod 'ConfigFile', path: '../ConfigFile'
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

  podspec :path => 'WebAPI.podspec'

  project_dependencies

  target 'WebAPI_tvOSTests' do
    inherit! :search_paths
  end
end

target 'WebAPI_macOS' do
  platform :osx, '10.10'

  podspec :path => 'WebAPI.podspec'

  project_dependencies

  target 'WebAPI_macOSTests' do
     inherit! :search_paths
  end
end

# post_install do |installer|
#   installer.pods_project.targets.each do |target|
#     puts target.name
#   end
# end
#
