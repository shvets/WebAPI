import PackageDescription

let package = Package(
  name: "WebAPI",
  dependencies: [
    .Package(url: "https://github.com/Alamofire/Alamofire", Version(4, 5, 0)),
    .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", Version(3, 1, 4)),
    .Package(url: "https://github.com/scinfu/SwiftSoup", Version(1, 4, 0)),
    .Package(url: "https://github.com/JohnSundell/Wrap.git", Version(2, 1, 1)),
    .Package(url: "https://github.com/JohnSundell/Unbox.git", Version(2, 4, 0))
  ]
)
