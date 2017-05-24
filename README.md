# WebAPI
Swift client and tests for accessing various APIs around the web

    # Documentation

## Language and Guidelines

https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language
https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift
https://swift.org/source-code/
https://developer.apple.com/ios/human-interface-guidelines
https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppStoreDistributionTutorial/Introduction/Introduction.html#//apple_ref/doc/uid/TP40013839
https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/index.html#//apple_ref/doc/uid/TP40010853
https://developer.apple.com/library/content/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007072
https://developer.apple.com/library/content/documentation/Miscellaneous/Conceptual/iPhoneOSTechOverview/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007898
https://developer.apple.com/library/content/documentation/DeveloperTools/Conceptual/debugging_with_xcode/chapters/about_debugging_w_xcode.html#//apple_ref/doc/uid/TP40015022
https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40012582

https://developer.apple.com/library/content/samplecode/UsingPhotosFramework/Introduction/Intro.html#//apple_ref/doc/uid/TP40014575-Intro-DontLinkElementID_2
https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165i
https://developer.apple.com/library/content/documentation/General/Reference/HLSAuthoringSpec/index.html#//apple_ref/doc/uid/TP40016596

https://developer.apple.com/library/content/documentation/General/Conceptual/AppleTV_PG/index.html#//apple_ref/doc/uid/TP40015241

https://github.com/Wolg/awesome-swift  

https://developer.apple.com/swift/blog/
https://developer.apple.com/tvos/resources/

https://github.com/neonichu/swiftpm-talk  

http://iswift.org/cookbook  

## Package Manager

https://swift.org/package-manager
https://github.com/apple/swift-package-manager/blob/master/Documentation/Reference.md
https://github.com/nikolasburk/swift-package-manager-tutorial

    # Projects

https://github.com/JustHTTP/Just
http://docs.justhttp.net/QuickStart.html
https://github.com/Zewo/Zewo
https://github.com/intere/tvOS-PopularMovies
https://github.com/tbaranes/AudioPlayerSwift
https://github.com/ChristianLysne/TVOS-Example
https://github.com/piemonte/Player
https://github.com/Sweebi/tvProgress

    # Commands

swift package generate-xcodeproj
swift package init --type=executable
swift package init --type=library
swift package fetch
swift build
swift test -l
swift test -s <testname>
swift package show-dependencies
swift package show-dependencies --format json

git tag 1.0.0
git push --tags

xcodebuild -showsdks # to get SDK
     
xcodebuild -list # to get Targets and Build Configurations

xcodebuild clean
    
xcodebuild build -sdk appletvos10.1 -configuration Debug -scheme WebAPI

xcodebuild test -scheme WebAPI

xcodebuild archive -sdk appletvos10.1 -configuration Release -scheme WebAPI -archivePath archive/WebAPI.xcarchive 


    # Tools
  
Objective-C to Swift
  
http://iswift.org/try

    # CocoaPods

http://www.tekramer.com/making-private-cross-platform-swift-frameworks-with-cocoapods/
https://www.raywenderlich.com/156971/cocoapods-tutorial-swift-getting-started
http://www.enekoalonso.com/articles/creating-swift-frameworks-for-ios-osx-and-tvos

    # Articles

https://habrahabr.ru/company/flapmyport/blog/311760/
https://habrahabr.ru/company/flapmyport/blog/312330/
http://shashikantjagtap.net/bdd-with-xcode-8-swift-3-cucumberish-and-xcfit-on-macos-sierra/
http://www.brianjcoleman.com/tvos-tutorial-video-app-in-swift/
https://habrahabr.ru/post/278573/
https://habrahabr.ru/post/278781/
https://habrahabr.ru/post/303512/
https://habrahabr.ru/post/303798/
http://strawberrycode.com/blog/simple-uicollectionview-pagination-with-api-and-realm-database/
https://medium.com/@dark_torch/working-with-localization-in-swift-4a87f0d393a4#.iimloj2nr
https://developer.apple.com/tvos/human-interface-guidelines/
https://developer.apple.com/library/content/documentation/General/Conceptual/AppleTV_PG/DetectingButtonPressesandGestures.html#//apple_ref/doc/uid/TP40015241-CH16-SW1
https://www.raywenderlich.com/136159/uicollectionview-tutorial-getting-started
http://shrikar.com/ios-swift-tutorial-uicollectionview-pinterest-layout/

    # Other

https://swift.libhunt.com

http://krakendev.io/blog

https://www.youtube.com/watch?v=XmLdEcq-QNI&feature=youtu.be&a
https://github.com/sanketfirodiya/tvOS
https://github.com/hamishtaplin/tvos-resources


http://www.brianjcoleman.com/tvos-tutorial-video-app-in-swift/#prettyPhoto
http://stackoverflow.com/questions/31735228/how-to-make-a-simple-collection-view-with-swift

https://www.youtube.com/watch?v=XmLdEcq-QNI&feature=youtu.be&a
https://www.themoviedb.org/documentation/api


https://icomoon.io/
https://linearicons.com/free
http://www.flaticon.com/free-icon


    # Install CocoaPods

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

2. Create targets-frameworks for each platform: "Demo.iOS, "Demo.tvOS", "Demo.macOS".

3. For each target go into "Build Settings", find "Product Name", and change it to "Demo"
by removing ".iOS", ".tvOS" and ".macOS" suffixes.


4. Add this statement to all *.h files:

#import <Foundation/Foundation.h>

5. Create "Demo.podspec" file with dependencies declared.
You can create it with this command:

```bash
pod spec create ThreeRingControl
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
target 'Demo.iOS' do
  platform :ios, '10.0'

  use_frameworks! # required for swift projects

  podspec :path => 'Demo.podspec'
end

target 'Demo.tvOS' do
  platform :tvos, '10.10'

  use_frameworks!

  podspec :path => 'Demo.podspec'
end

target 'Demo.macOS' do
  platform :macos, '10.10'

  use_frameworks!

  podspec :path => 'Demo.podspec'
end
```

7. Install pod:

```
pod install
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

Links:

https://www.raywenderlich.com/126365/ios-frameworks-tutorial



