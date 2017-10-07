import Foundation

extension AudioBooAPI {
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
    //public let duration: String
    public let sources: [BooSource]

    enum CodingKeys: String, CodingKey {
      case title
      case orig
      case image
      //case duration
      case sources
    }

    public var url: String {
      get {
        return "\(AudioBooAPI.ArchiveUrl)\(sources[0].file)"
      }
    }

//  public var thumb: String {
//    get {
//      return "\(AudioBooAPI.SiteUrl)\(image)"
//    }
//  }
  }
}
