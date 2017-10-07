import Foundation

extension AudioKnigiAPI {
  public struct PersonName {
    public let name: String
    public let id: String

    public init(name: String, id: String) {
      self.name = name
      self.id = id
    }
  }

  public struct Track: Codable {
    public let albumName: String
    public let title: String
    public let url: String
    public let time: Int

    enum CodingKeys: String, CodingKey {
      case albumName = "cat"
      case title
      case url = "mp3"
      case time
    }

    public init(albumName: String, title: String, url: String, time: Int) {
      self.albumName = albumName
      self.title = title
      self.url = url
      self.time = time
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      let albumName = try? container.decodeIfPresent(String.self, forKey: .albumName) ?? ""
      let title = try container.decodeIfPresent(String.self, forKey: .title)
      let url = try container.decodeIfPresent(String.self, forKey: .url)
      let time = try container.decodeIfPresent(String.self, forKey: .time)

      self.init(albumName: albumName ?? "",
        title: title ?? "",
        url: url ?? "",
        time: Int(time ?? "0") ?? 0
      )
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)

      try container.encode(albumName, forKey: .albumName)
      try container.encode(title, forKey: .title)
      try container.encode(url, forKey: .url)
      try container.encode(time, forKey: .time)
    }
  }
}
