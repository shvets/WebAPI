import PackageDescription

let package = Package(
  name: "WebAPI",
  dependencies: [
    .Package(url: "https://github.com/JustHTTP/Just.git", Version(0, 5, 7)),
    .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", Version(3, 1, 4)),
    .Package(url: "https://github.com/scinfu/SwiftSoup", Version(1, 2, 4))
  ]
)
