// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "WebAPI",
  platforms: [
    .macOS(.v10_12),
    .iOS(.v10),
    .tvOS(.v10)
  ],
  products: [
    .library(name: "WebAPI", type: .dynamic, targets: ["WebAPI"]),
    .executable(name: "grabbook", targets: ["GrabBook"])
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire", from: "4.7.3"),
    .package(url: "https://github.com/ReactiveX/RxSwift", from: "4.3.1"),
    //.package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.1.0"),
    .package(url: "https://github.com/scinfu/SwiftSoup", from: "1.7.4"),
    .package(url: "https://github.com/JohnSundell/Files", from: "2.0.1"),
    .package(url: "https://github.com/shvets/ConfigFile", from: "1.1.0")
  ],
  targets: [
    .target(
      name: "WebAPI",
      dependencies: [
        "Alamofire",
        "SwiftSoup",
        //"SwiftyJSON",
        "Files",
        "ConfigFile",
        "RxSwift"
      ]),
    .target(
      name: "GrabBook",
      dependencies: [
        "WebAPI"
      ]),
    .testTarget(
      name: "WebAPITests",
      dependencies: [ "WebAPI" ],
      path: "Tests"
    )
  ],
  swiftLanguageVersions: [.v5]
)
