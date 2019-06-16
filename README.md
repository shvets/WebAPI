# WebAPI
Swift client and tests for accessing various APIs around the web

    # Documentation
https://www.thedroidsonroids.com/blog/ios/rxswift-by-examples-1-the-basics/
https://github.com/ReactiveX/RxSwift/blob/master/Documentation/GettingStarted.md
https://gist.github.com/staltz/868e7e9bc2a7b8c1f754

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

http://martiancraft.com/blog/2017/05/demystifying-ios-provisioning-part1/
http://martiancraft.com/blog/2017/07/demystifying-provisioning-part2/

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
swift package resolve
swift build
swift test -l
swift test -s <testname>
swift package show-dependencies
swift package show-dependencies --format json
swift -I .build/debug -L .build/debug -lWebAPI

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
https://www.raywenderlich.com/126365/ios-frameworks-tutorial
https://guides.cocoapods.org/making/private-cocoapods.html

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

https://www.bignerdranch.com/blog/10-tips-for-mastering-the-focus-engine-on-tvos/

https://stackblitz.com/

swift build
./.build/debug/grabbook --boo http://audioboo.ru/klassika/27678-kipling-redyard-rasskazy.html
http://audioboo.ru/didiktiva/22797-akunin-boris-priklyucheniya-erasta-fandorina-16-ne-proschayus.html
./.build/debug/grabbook --zvook http://bookzvuk.ru/zhizn-i-neobyichaynyie-priklyucheniya-soldata-ivana-chonkina-1-litso-neprikosnovennoe-vladimir-voynovich-audiokniga-onlayn
