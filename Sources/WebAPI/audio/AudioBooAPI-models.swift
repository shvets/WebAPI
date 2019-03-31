import Foundation

extension AudioBooAPI {
  public struct PersonName {
    public let name: String
    public let id: String

    public init(name: String, id: String) {
      self.name = name
      self.id = id
    }
  }
  
  public struct BooSource: Codable {
    public let file: String
    public let type: String
    public let height: String
    public let width: String
  }

  public struct BooTrack: Codable {
    public let title: String
    public let orig: String
    public let image: String
    public let duration: String
    public let sources: [BooSource]

    enum CodingKeys: String, CodingKey {
      case title
      case orig
      case image
      case duration
      case sources
    }

    public var url: String {
      get {
        print(sources[0].file)
        return "\(AudioBooAPI.ArchiveUrl)\(sources[0].file)"
      }
    }

//  public var thumb: String {
//    get {
//      return "\(AudioBooAPI.SiteUrl)\(image)"
//    }
//  }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      title = try container.decode(String.self, forKey: .title)
      orig = try container.decode(String.self, forKey: .orig)

      do {
        image = try container.decode(forKey: .image, default: "")
      }
      catch {
        image = ""
      }

      do {
        duration = try container.decode(forKey: .duration, default: "")
      }
      catch {
        duration = ""
      }

      sources = try container.decode(forKey: .sources, default: [] as [BooSource])
    }
  }
}
