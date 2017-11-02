// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "WebAPI",
  products: [
    .library(name: "WebAPI", targets: ["WebAPI"]),
    .executable(name: "grabbook", targets: ["GrabBook"])
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire", from: "4.5.1"),
    .package(url: "https://github.com/ReactiveX/RxSwift", from: "4.0.0"),
    .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "3.1.4"),
    .package(url: "https://github.com/scinfu/SwiftSoup", from: "1.5.5"),
    .package(url: "https://github.com/JohnSundell/Files", from: "1.9.0"),
    .package(url: "https://github.com/shvets/ConfigFile", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "WebAPI",
      dependencies: [
        "Alamofire",
        "SwiftSoup",
        "SwiftyJSON",
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
  swiftLanguageVersions: [4]
)
