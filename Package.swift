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
    .package(url: "https://github.com/scinfu/SwiftSoup", from: "1.5.2")
  ],
  targets: [
    .target(
      name: "WebAPI",
      dependencies: [
        "Alamofire",
        "SwiftSoup"
      ]),
    .target(
      name: "GrabBook",
      dependencies: [
        "WebAPI"
      ]),
    .testTarget(name: "WebAPITests", dependencies: ["WebAPI"], path: "Tests")
  ],
  swiftLanguageVersions: [4]
)
