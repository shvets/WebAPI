import PackageDescription

let package = Package(
  name: "WebAPI",
  dependencies: [
    .Package(url: "https://github.com/JustHTTP/Just.git", majorVersion: 0, minor: 5),
    .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", Version(3, 1, 3)),
//    .Package(url: "https://github.com/tid-kijyun/Kanna", Version(2, 1, 1))
    .Package(url: "https://github.com/scinfu/SwiftSoup", Version(1, 1, 5)),
//    .Package(url: "https://github.com/shvets/HTMLReader", Version(2, 0, 1))
  ]
)
