import Foundation

extension EtvnetAPI {
  public enum WatchStatus: Int, RawRepresentable, Codable {
    case new = 0
    case partiallyWatched
    case finished

  public typealias RawValue = Int

  public init?(rawValue: RawValue) {
    switch rawValue {
      case 0: self = .new
      case 1: self = .partiallyWatched
      case 2: self = .finished
      default: self = .new
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .new: return 0
      case .partiallyWatched: return 1
      case .finished: return 2
    }
  }

  public var description: String {
    switch self {
      case .new: return "New"
      case .partiallyWatched: return "Partially Watched"
      case .finished: return "Finished"
    }
  }
}

  public struct UrlType: Codable {
    public let url: String
  }

  public struct Name: Codable {
    public let id: Int
    public let name: String
  }

  public struct Genre: Codable {
    public let id: Int
    public let name: String
    public let count: Int
  }

  public struct FileType: Codable {
    public let bitrate: Int
    public let format: String

    public init(bitrate: Int, format: String) {
      self.bitrate = bitrate
      self.format = format
    }
  }

  public enum MediaType: String, Codable {
    case container = "Container"
    case mediaObject = "MediaObject"
  }

  public struct MarkType: Codable {
    public let total: Int
    public let count: Int

    public init(total: Int, count: Int) {
      self.total = total
      self.count = count
    }
  }

  public struct Media: Codable {
    public let id: Int
    public let name: String
    public let seriesNum: Int
    public let onAir: String
    public let duration: Int
    public let country: String
    public let childrenCount: Int
    public let isHd: Bool
    public let files: [FileType]
    public let channel: Name
    public let shortName: String
    public let shortNameEng: String
    public let watchStatus: WatchStatus
    public let tag: String
    public let year: Int
    public let mediaType: MediaType
    public let parent: Int
    public let thumb: String
    public let mark: MarkType
    public let rating: Int
    public let description: String

    enum CodingKeys: String, CodingKey {
      case id
      case name
      case seriesNum = "series_num"
      case onAir = "on_air"
      case duration
      case country
      case childrenCount = "children_count"
      case isHd = "is_hd"
      case files
      case channel
      case shortName = "short_name"
      case shortNameEng = "short_name_eng"
      case watchStatus = "watch_status"
      case tag
      case year
      case mediaType = "type"
      case parent
      case thumb
      case mark
      case rating
      case description
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      id = try container.decode(Int.self, forKey: .id)
      name = try container.decode(String.self, forKey: .name)
      seriesNum = try container.decode(Int.self, forKey: .seriesNum)
      onAir = try container.decode(String.self, forKey: .onAir)
      duration = try container.decode(Int.self, forKey: .duration)
      country = try container.decode(String.self, forKey: .country)
      childrenCount = try container.decode(Int.self, forKey: .childrenCount)
      isHd = try container.decode(Bool.self, forKey: .isHd)

      do {
        files = (try container.decode(forKey: .files, default: []))
      }
      catch {
        files = []
      }

      channel = try container.decode(Name.self, forKey: .channel)
      shortName = try container.decode(String.self, forKey: .shortName)
      shortNameEng = try container.decode(String.self, forKey: .shortNameEng)
      watchStatus = try container.decode(WatchStatus.self, forKey: .watchStatus)
      tag = try container.decode(String.self, forKey: .tag)

      // bug in REST API: sometimes returns empty string
      do {
        year = try container.decode(forKey: .year, default: 0)
      }
      catch {
        year = 0
      }

      mediaType = try container.decode(MediaType.self, forKey: .mediaType)
      parent = try container.decode(Int.self, forKey: .parent)
      thumb = try container.decode(String.self, forKey: .thumb)
      mark = try container.decode(MarkType.self, forKey: .mark)
      rating = try container.decode(Int.self, forKey: .rating)
      description = try container.decode(String.self, forKey: .description)
    }
  }

  public struct Show: Codable {
    public let title: String
    public let startTime: String
    public let finishTime: String

    enum CodingKeys: String, CodingKey {
      case title
      case startTime = "start_time"
      case finishTime = "finish_time"
    }
  }

  public struct LiveChannel: Codable {
    public let id: Int
    public let name: String
////    public let liveFormat: String
////    public let favorite: Bool
//    public let offset: String
    public let allowed: Int
////    public let currentShow: Show
////    public let tvShows: [String]
    public let files: [FileType]
    public let icon: URL?

    enum CodingKeys: String, CodingKey {
      case id
      case name
//      case offset
      case allowed
////      case currentShow = "current_show"
////      case liveFormat = "live_format"
////      case favorite
////      case tvShows = "tv_shows"
      case files
      case icon
    }

    public init(name: String, id: Int, allowed: Int, files: [FileType], icon: URL?) {

    //}, offset: String, allowed: Int, files: [FileType], icon: URL?) {
      self.name = name
      self.id = id
//      self.offset = offset
      self.allowed = allowed
//
//      self.liveFormat = liveFormat
//      self.favorite = favorite
//      self.tvShows = tvShows

      self.files = files
      self.icon = icon
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      let name = try container.decode(String.self, forKey: .name)
      let id = try container.decode(Int.self, forKey: .id)
//      let offset = try container.decode(String.self, forKey: .offset)
      let allowed = try container.decode(Int.self, forKey: .allowed)
//      //let liveFormat = try container.decode(String.self, forKey: .liveFormat)
//      //let favorite = try container.decode(Bool.self, forKey: .favorite)
      let files = try container.decode([FileType].self, forKey: .files)
      let icon = try container.decodeIfPresent(URL.self, forKey: .icon)

      self.init(name: name, id: id, allowed: allowed, files: files, icon: icon)
      //, offset: offset, allowed: allowed,  files: files, icon: icon)
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)

      try container.encode(name, forKey: .name)
      try container.encode(id, forKey: .id)
//      try container.encode(offset, forKey: .offset)
      try container.encode(allowed, forKey: .allowed)
      try container.encode(files, forKey: .files)
      try container.encode(icon, forKey: .icon)
    }
  }

  public struct Pagination: Codable {
    public let pages: Int
    public let page: Int
    public let perPage: Int
    public let start: Int
    public let end: Int
    public let count: Int
    public let hasNext: Bool
    public let hasPrevious: Bool

    enum CodingKeys: String, CodingKey {
      case pages
      case page
      case perPage = "per_page"
      case start
      case end
      case count
      case hasNext = "has_next"
      case hasPrevious = "has_previous"
    }
  }

  public struct PaginatedMediaData: Codable {
    public let media: [Media]
    public let pagination: Pagination
  }

  public struct PaginatedChildrenData: Codable {
    public let children: [Media]
    public let pagination: Pagination
  }

  public struct PaginatedBookmarksData: Codable {
    public let bookmarks: [Media]
    public let pagination: Pagination
  }

  public enum MediaData: Encodable {
    case paginatedMedia(PaginatedMediaData)
    case paginatedBookmarks(PaginatedBookmarksData)
    case paginatedChildren(PaginatedChildrenData)
    case names([Name])
    case genres([Genre])
    case liveChannels([LiveChannel])
    case url(UrlType)
    case none

    public func encode(to encoder: Encoder) throws {}
  }

  public struct MediaResponse: Codable {
    public let errorCode: String
    public let errorMessage: String
    public let statusCode: Int
    public let data: MediaData

    enum CodingKeys: String, CodingKey {
      case errorCode = "error_code"
      case errorMessage = "error_message"
      case statusCode = "status_code"
      case data
    }

    public init(errorCode: String, errorMessage: String, statusCode: Int, data: MediaData) {
      self.errorCode = errorCode
      self.errorMessage = errorMessage
      self.statusCode = statusCode
      self.data = data
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      let errorCode = try container.decode(forKey: .errorCode, default: "")
      let errorMessage = try container.decode(forKey: .errorMessage, default: "")
      let statusCode = try container.decode(forKey: .statusCode, default: 0)

      let paginatedMedia = try? container.decodeIfPresent(PaginatedMediaData.self, forKey: .data)
      let paginatedChildren = try? container.decodeIfPresent(PaginatedChildrenData.self, forKey: .data)
      let paginatedBookmarks = try? container.decodeIfPresent(PaginatedBookmarksData.self, forKey: .data)
      let genres = try? container.decodeIfPresent([Genre].self, forKey: .data)
      let names = try? container.decodeIfPresent([Name].self, forKey: .data)
      let liveChannels = try? container.decodeIfPresent([LiveChannel].self, forKey: .data)
      let url = try? container.decodeIfPresent(UrlType.self, forKey: .data)

      var data: MediaData?

      if let value = paginatedMedia, value != nil {
        data = MediaData.paginatedMedia(value!)
      }
      else if let value = paginatedChildren, value != nil {
        data = MediaData.paginatedChildren(value!)
      }
      else if let value = paginatedBookmarks, value != nil {
        data = MediaData.paginatedBookmarks(value!)
      }
      else if let value = genres, value != nil {
        data = MediaData.genres(value!)
      }
      else if let value = liveChannels, value != nil {
        data = MediaData.liveChannels(value!)
      }
      else if let value = names, value != nil {
        data = MediaData.names(value!)
      }
      else if let value = url, value != nil {
        data = MediaData.url(value!)
      }
      else {
        data = MediaData.none
      }

      self.init(errorCode: errorCode, errorMessage: errorMessage, statusCode: statusCode, data: data!)
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)

      try container.encode(errorCode, forKey: .errorCode)
      try container.encode(errorMessage, forKey: .errorMessage)
      try container.encode(statusCode, forKey: .statusCode)

      try container.encode(data, forKey: .data)
    }
  }

  public struct BookmarkResponse: Codable {
    public let status: String
  }

}
