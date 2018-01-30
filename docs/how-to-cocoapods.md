
1. Install latest ruby

```bash
rvm install ruby
ruby -v
gem -v
```

2. Install cocoapods gem:

```bash
gem install cocoapods
```

3. Install CocoaPods (~/.cocoapods)

```bash
pod setup --verbose
```

4. Generate Podfile for existing xcode project:

```bash
pod init
```

    # Multi-platform Projects

1. Create empty project (in "Other" section): "Demo."

2. Create targets-frameworks for each platform: "Demo_iOS, "Demo_tvOS", "Demo_macOS" with tests selected.

For each test-target go to "Build Settings" | "All" and "Combined". Under "Build Options" you should see 
"Always Embed Swift Standard Libraries" - specify "$(inherited)".

3. For each target go into "Build Settings", find "Product Name", and change it to "Demo"
by removing ".iOS", ".tvOS" and ".macOS" suffixes.


4. Add this statement to all *.h files:

#import <Foundation/Foundation.h>

5. Create "Demo.podspec" file with dependencies declared.
You can create it with this command:

```bash
pod spec create Demo
```

```ruby
Pod::Spec.new do |s|
  #...
  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"

  #...

  s.dependency 'Alamofire', '4.4'
  #...
end
```

6. Create "Podfile". It will pull dependencies from "Demo.podspec" file

```ruby
target 'Demo_iOS' do
  platform :ios, '10.0'

  use_frameworks! # required for swift projects

  podspec :path => 'Demo.podspec'
end

target 'Demo_tvOS' do
  platform :tvos, '10.10'

  use_frameworks!

  podspec :path => 'Demo.podspec'
end

target 'Demo_macOS' do
  platform :macos, '10.10'

  use_frameworks!

  podspec :path => 'Demo.podspec'
end
```

7. Install pod:

```
pod install
pod install --repo-update
```

8. Close Demo.xcodeproj and open generated Demo.xcworkspace

9. If you have existing files, add them to "Demo" folder. Make sure they are added to targets 
in the File Inspector under Target Membership.

10. Create tag for versioning:

```bash
git tag 1.0.0
git push origin 1.0.0
```

11. In new project add it as dependency:

```ruby
pod 'Demo', :git => 'URL', :tag => '1.0.0'

# or in order to test locally

pod 'Demo', :path => '../Demo'
```

Run update command:

```bash
pod update
```

Links

http://www.tekramer.com/making-private-cross-platform-swift-frameworks-with-cocoapods/
https://www.raywenderlich.com/156971/cocoapods-tutorial-swift-getting-started
http://www.enekoalonso.com/articles/creating-swift-frameworks-for-ios-osx-and-tvos
https://www.raywenderlich.com/126365/ios-frameworks-tutorial
https://guides.cocoapods.org/making/private-cocoapods.html
