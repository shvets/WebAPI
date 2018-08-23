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

  public struct Tracks: Codable {
    public let aItems: [Track]
    public let bStateError: Bool
    public let fstate: Bool
    public let sMsg: String
    public let sMsgTitle: String

    public init(aItems: [Track], bStateError: Bool, fstate: Bool, sMsg: String, sMsgTitle: String) {
      self.aItems = aItems
      self.bStateError = bStateError
      self.fstate = fstate
      self.sMsg = sMsg
      self.sMsgTitle = sMsgTitle
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

      let albumName = try container.decode(forKey: .albumName, default: "")
      let title = try container.decode(forKey: .title, default: "")
      let url = try container.decode(forKey: .url, default: "")
      let time = Int(try container.decode(forKey: .time, default: "0"))!

      self.init(albumName: albumName, title: title, url: url, time: time)
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
