import PackageDescription

let package = Package(
  name: "WebAPI",
  dependencies: [
    .Package(url: "https://github.com/Alamofire/Alamofire", Version(4, 5, 1)),
    .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", Version(3, 1, 4)),
    .Package(url: "https://github.com/scinfu/SwiftSoup", Version(1, 5, 0))
  ]
)
