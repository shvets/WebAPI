import Foundation
import ConfigFile
import RxSwift

open class EtvnetAPI: ApiService {
  public static let PER_PAGE = 15

  let ApiUrl = "https://secure.etvnet.com/api/v3.0/"
  let UserAgent = "Etvnet User Agent"

  let AuthUrl = "https://accounts.etvnet.com/auth/oauth/"
  let ClientId = "a332b9d61df7254dffdc81a260373f25592c94c9"
  let ClientSecret = "744a52aff20ec13f53bcfd705fc4b79195265497"

  let Scope = [
    "com.etvnet.media.browse",
    "com.etvnet.media.watch",
    "com.etvnet.media.bookmarks",
    "com.etvnet.media.history",
    "com.etvnet.media.live",
    "com.etvnet.media.fivestar",
    "com.etvnet.media.comments",
    "com.etvnet.persons",
    "com.etvnet.notifications"
  ].joined(separator: " ")

  let GrantType = "http://oauth.net/grant_type/device/1.0"

  let TimeShift = [
    "0": 0,  // Moscow
    "1": 2,  // Berlin
    "2": 3,  // London
    "3": 8,  // New York
    "4": 9,  // Chicago
    "5": 10, // Denver
    "6": 11  // Los Angeles
  ]

  public static let Topics = ["etvslider/main", "newmedias", "best", "top", "newest", "now_watched", "recommend"]

  let decoder = JSONDecoder()

  public init(config: StringConfigFile) {
    super.init(config: config, apiUrl: ApiUrl, userAgent: UserAgent, authUrl: AuthUrl, clientId: ClientId,
      clientSecret: ClientSecret, grantType: GrantType, scope: Scope)
  }

  func tryCreateToken(userCode: String, deviceCode: String,
                      activationUrl: String) -> AuthProperties? {
    print("Register activation code on web site \(activationUrl): \(userCode)")

    var result: AuthProperties?

    var done = false

    while !done {
      result = createToken(deviceCode: deviceCode)

      if let result = result {
        done = result.accessToken != nil
      }

      if !done {
        sleep(5)
      }
    }

    if let result = result {
      config.items = result.asDictionary()
      saveConfig()
    }

    return result
  }

  public func getChannels(today: Bool = false) -> [Name] {
    let path = "video/channels.json"

    let url = buildUrl(path: path, params: ["today": String(today) as AnyObject])

    if let response = fullRequest(path: url) {
      if let data = response.data {
        if let result = try? decoder.decode(MediaResponse.self, from: data).data {
          if case .names(let channels) = result {
            return channels
          }
        }
      }
    }

    return []
  }

  public func getArchive(genre: Int? = nil, channelId: Int? = nil, perPage: Int=PER_PAGE, page: Int=1) -> PaginatedMediaData? {
    var path: String

    if channelId != nil && genre != nil {
      path = "video/media/channel/\(channelId!)/archive/\(genre!).json"
    }
    else if genre != nil {
      path = "video/media/archive/\(genre!).json"
    }
    else if channelId != nil {
      path = "video/media/channel/\(channelId!)/archive.json"
    }
    else {
      path = "video/media/archive.json"
    }

    var params = [String: String]()
    params["per_page"] = String(perPage)
    params["page"] = String(page)

    let url = buildUrl(path: path, params: params as [String : AnyObject])

    if let response = fullRequest(path: url) {
      if let data = response.data {
        if let result = try? decoder.decode(MediaResponse.self, from: data).data {
          if case .paginatedMedia(let value) = result {
            return value
          }
        }
      }
    }

    return nil
  }

  public func getArchive2(genre: Int? = nil, channelId: Int? = nil, perPage: Int=PER_PAGE, page: Int=1) -> Observable<EtvnetAPI.PaginatedMediaData?> {
    var path: String

    if channelId != nil && genre != nil {
      path = "video/media/channel/\(channelId!)/archive/\(genre!).json"
    }
    else if genre != nil {
      path = "video/media/archive/\(genre!).json"
    }
    else if channelId != nil {
      path = "video/media/channel/\(channelId!)/archive.json"
    }
    else {
      path = "video/media/archive.json"
    }

    var params = [String: String]()
    params["per_page"] = String(perPage)
    params["page"] = String(page)

    let url = buildUrl(path: path, params: params as [String : AnyObject])

    return fullRequestRx(path: url).map { data in
      if let result = try? self.decoder.decode(MediaResponse.self, from: data).data {
        if case .paginatedMedia(let value) = result {
          return value
        }
      }
      
      return nil
    }
  }

  public func getGenres(parentId: String? = nil, today: Bool=false, channelId: String? = nil, format: String? = nil) -> [Genre] {
    let path = "video/genres.json"
    let todayString: String? = today ? "yes" : nil

    var params = [String: String]()
    params["parent"] = parentId
    params["today"] = todayString
    params["channel"] = channelId
    params["format"] = format

    let url = buildUrl(path: path, params: params as [String : AnyObject])

    if let response = fullRequest(path: url) {
      if let data = response.data {
        if let result = try? decoder.decode(MediaResponse.self, from: data).data {
          if case .genres(let genres) = result {
            // regroup genres

            var regrouped = [Genre]()

            regrouped.append(genres[0])
            regrouped.append(genres[1])
            regrouped.append(genres[5])
            regrouped.append(genres[9])

            regrouped.append(genres[7])
            regrouped.append(genres[2])
            regrouped.append(genres[3])
            regrouped.append(genres[4])

            regrouped.append(genres[6])
            regrouped.append(genres[8])
            regrouped.append(genres[10])
            regrouped.append(genres[11])

            regrouped.append(genres[12])
            // regrouped.append(genres[13])
            regrouped.append(genres[14])
            // regrouped.append(genres[15])

            return regrouped
          }
        }
      }
    }

    return []
  }

  public func getGenre(_ genres: [Genre], name: String) -> Int? {
    var found: Int?

    for genre in genres {
      if genre.name == name {
        found = genre.id

        break
      }
    }

    return found
  }

  public func getBlockbusters(perPage: Int=PER_PAGE, page: Int=1) -> PaginatedMediaData? {
    let genres = getGenres()

    let genre = getGenre(genres, name: "Блокбастеры")

    return getArchive(genre: genre, perPage: perPage, page: page)
  }

//  public func getBlockbusters(perPage: Int=PER_PAGE, page: Int=1) -> Observable<PaginatedMediaData?> {
//    let genres = getGenres()
//
//    let genre = getGenre(genres, name: "Блокбастеры")
//
//    return getArchive2(genre: genre, perPage: perPage, page: page)
//  }

  public func getCoolMovies(perPage: Int=PER_PAGE, page: Int=1) -> PaginatedMediaData? {
    return getArchive(channelId: 158, perPage: perPage, page: page)
  }

  public func search(_ query: String, perPage: Int=PER_PAGE, page: Int=1, dir: String? = nil) -> PaginatedMediaData? {
    var newDir = dir

    if newDir == nil {
      newDir = "desc"
    }

    let path = "video/media/search.json"

    var params = [String: String]()
    params["q"] = query
    params["per_page"] = String(perPage)
    params["page"] = String(page)
    params["dir"] = dir

    let url = buildUrl(path: path, params: params as [String : AnyObject])

    if let response = fullRequest(path: url) {
      if let data = response.data {
        if let result = try? decoder.decode(MediaResponse.self, from: data).data {
          if case .paginatedMedia(let value) = result {
            return value
          }
        }
      }
    }

    return nil
  }

  public func getNewArrivals(genre: String? = nil, channelId: String? = nil, perPage: Int=PER_PAGE, page: Int=1) -> PaginatedMediaData? {
    var path: String

    if channelId != nil && genre != nil {
      path = "video/media/channel/\(channelId!)/new_arrivals/\(genre!).json"
    }
    else if genre != nil {
      path = "video/media/new_arrivals/\(genre!).json"
    }
    else if channelId != nil {
      path = "video/media/channel/\(channelId!)/new_arrivals.json"
    }
    else {
      path = "video/media/new_arrivals.json"
    }

    var params = [String: String]()
    params["per_page"] = String(perPage)
    params["page"] = String(page)

    let url = buildUrl(path: path, params: params as [String : AnyObject])

    if let response = fullRequest(path: url) {
      if let data = response.data {
        if let result = try? decoder.decode(MediaResponse.self, from: data).data {
          if case .paginatedMedia(let value) = result {
            return value
          }
        }
      }
    }

    return nil
  }

  public func getHistory(perPage: Int=PER_PAGE, page: Int=1) -> PaginatedMediaData? {
    var params = [String: String]()

    params["per_page"] = String(perPage)
    params["page"] = String(page)

    let path = "video/media/history.json"

    let url = buildUrl(path: path, params: params as [String : AnyObject])

    if let response = fullRequest(path: url) {
      if let data = response.data {
        if let result = try? decoder.decode(MediaResponse.self, from: data).data {
          if case .paginatedMedia(let value) = result {
            return value
          }
        }
      }
    }

    return nil
  }

  public func getLiveChannelUrl(_ channelId: Int, format: String="mp4", mediaProtocol: String="hls",
                                 bitrate: String? = nil, otherServer: String? = nil, offset: String? = nil) -> [String: String] {
    return getUrl(0, format: format, mediaProtocol: mediaProtocol, bitrate: bitrate, otherServer: otherServer,
      offset: offset, live: true, channelId: channelId, preview: false)
  }

  public func getUrl(_ mediaId: Int, format: String="mp4", mediaProtocol: String="hls", bitrate: String? = nil,
                      otherServer: String? = nil, offset: String? = nil, live: Bool=false,
                      channelId: Int? = nil, preview: Bool=false) -> [String: String] {
    //var result = [String: String]()

    var newFormat = format
    var newMediaProtocol: String? = mediaProtocol

    if format == "zixi" {
      newFormat = "mp4"
    }

    let path: String
    var params: [String: String]

    if live {
      path = "video/live/watch/\(channelId!).json"

      params = ["format": newFormat]

      if offset != nil {
        params["offset"] = offset!
      }

      if bitrate != nil {
        params["bitrate"] = bitrate!
      }

      if otherServer != nil {
        params["other_server"] = otherServer!
      }
    }
    else {
      if format == "wmv" {
        newMediaProtocol = nil
      }

      if newFormat == "mp4" && mediaProtocol != "hls" {
        newMediaProtocol = "rtmp"
      }

      let link_type: String

      if preview {
        link_type = "preview"
      }
      else {
        link_type = "watch"
      }

      path = "video/media/\(mediaId)/\(link_type).json"

      params = ["format": newFormat]

      if newMediaProtocol != nil {
        params["protocol"] = newMediaProtocol!
      }

      if bitrate != nil {
        params["bitrate"] = bitrate!
      }

      if otherServer != nil {
        params["other_server"] = otherServer!
      }
    }

    let url = buildUrl(path: path, params: params as [String : AnyObject])

    if let response = fullRequest(path: url) {
      if let data = response.data {
        if let result = try? decoder.decode(MediaResponse.self, from: data) {
          if case .url(let value) = result.data {
            //let itemUrl = value.url

            var urlInfo = [String: String]()

            urlInfo["url"] = value.url
            urlInfo["format"] =  newFormat

            if newMediaProtocol != nil {
              urlInfo["protocol"] = newMediaProtocol
            }

            return urlInfo
          }
        }
      }
    }

    return [:]
  }

  public func getChildren(_ mediaId: Int, perPage: Int=PER_PAGE, page: Int=1, dir: String?=nil) -> PaginatedChildrenData? {
    let path = "video/media/\(mediaId)/children.json"

    var params = [String: String]()
    params["per_page"] = String(perPage)
    params["page"] = String(page)
    params["dir"] = dir

    let url = buildUrl(path: path, params: params as [String : AnyObject])

    if let response = fullRequest(path: url) {
      if let data = response.data {
        if let result = try? decoder.decode(MediaResponse.self, from: data).data {
          if case .paginatedChildren(let value) = result {
            return value
          }
        }
      }
    }

    return nil
  }

  public func getBookmarks(folder: String? = nil, perPage: Int=PER_PAGE, page: Int=1) -> PaginatedBookmarksData? {
    let params = ["per_page": String(perPage), "page": String(page)]

    var path: String

    if folder != nil {
      path = "video/bookmarks/folders/\(folder!)/items.json"
    }
    else {
      path = "video/bookmarks/items.json"
    }

    let url = buildUrl(path: path, params: params as [String : AnyObject])

    if let response = fullRequest(path: url) {
      if let data = response.data {
        if let result = try? decoder.decode(MediaResponse.self, from: data).data {
          if case .paginatedBookmarks(let value) = result {
            return value
          }
        }
      }
    }

    return nil
  }
//
//  public func getFolders(perPage: Int=PER_PAGE) -> JSON {
//    let url = buildUrl(path: "video/bookmarks/folders.json")
//
//    let response = fullRequest(path: url)
//
//    return JSON(data: response!.data!)
//  }

  public func getBookmark(id: Int) -> Media? {
    let url = buildUrl(path: "video/bookmarks/items/\(id).json")

    if let response = fullRequest(path: url) {
      if let data = response.data {
        if let result = try? decoder.decode(MediaResponse.self, from: data).data {
          if case .paginatedBookmarks(let value) = result {
            return value.bookmarks[0]
          }
        }
      }
    }

    return nil
  }

  public func addBookmark(id: Int) -> Bool {
    let url = buildUrl(path: "video/bookmarks/items/\(id).json")

    if let response = fullRequest(path: url, method: .post) {
      let statusCode = response.response!.statusCode
      let data = response.data

      if statusCode == 201 && data != nil {
        if let result = try? decoder.decode(BookmarkResponse.self, from: data!) {
          return result.status == "Created"
        }
      }
    }

    return false
  }

  public func removeBookmark(id: Int) -> Bool {
    let url = buildUrl(path: "video/bookmarks/items/\(id).json")

    if let response = fullRequest(path: url, method: .delete) {
      let statusCode = response.response!.statusCode
      let data = response.data

      if statusCode == 204 && data != nil {
        //let result = try? decoder.decode(BookmarkResponse.self, from: data!)

        return true
      }
    }

    return false
  }

  public func getTopicItems(_ id: String="best", perPage: Int=PER_PAGE, page: Int=1) -> PaginatedMediaData? {
    var params = [String: String]()
    params["per_page"] = String(perPage)
    params["page"] = String(page)

    let url = buildUrl(path: "video/media/\(id).json", params: params as [String : AnyObject])

    if let response = fullRequest(path: url) {
      if let data = response.data {
        if let result = try? decoder.decode(MediaResponse.self, from: data).data {
          if case .paginatedMedia(let value) = result {
            return value
          }
        }
      }
    }

    return nil
  }

  public func getLiveChannels(favoriteOnly: Bool=false, offset: String? = nil, category: Int=0) -> [LiveChannel] {
    let format = "mp4"

    var params = ["format": format, "allowed_only": String(1), "favorite_only": String(favoriteOnly)]

    if offset != nil {
      params["offset"] = offset
    }

    var path: String

    if category > 0 {
      path = "video/live/category/\(category).json?"
    }
    else {
      path = "video/live/channels.json"
    }

    let url = buildUrl(path: path, params: params as [String : AnyObject])

    if let response = fullRequest(path: url) {
      if let data = response.data {
        if let result = try? decoder.decode(MediaResponse.self, from: data).data {
          if case .liveChannels(let liveChannels) = result {
            return liveChannels
          }
        }
      }
    }

    return []
  }

  public func addFavoriteChannel(id: Int) -> Bool {
    let url = buildUrl(path: "video/live/\(id)/favorite.json")

    let _ = fullRequest(path: url, method: .post)

    return true
  }

  public func removeFavoriteChannel(id: Int) -> Bool {
    let url = buildUrl(path: "video/live/\(id)/favorite.json")

    let _ = fullRequest(path: url, method: .delete)

    return true
  }

//  public func getLiveSchedule(liveChannelId: String, date: Date = Date()) -> JSON {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd@nbsp;HH:mm"
//
//    let dateString = dateFormatter.string(from: date)
//
//    let params = ["date": dateString]
//
//    let path = "video/live/schedule/\(liveChannelId).json"
//
//    let url = buildUrl(path: path, params: params as [String : AnyObject])
//
//    let response = fullRequest(path: url)
//
//    return JSON(data: response!.data!)
//  }

  public func getLiveCategories() -> [Name] {
    let url = buildUrl(path: "video/live/category.json")

    if let response = fullRequest(path: url) {
      if let data = response.data {
        if let result = try? decoder.decode(MediaResponse.self, from: data).data {
          if case .names(let categories) = result {
            // regroup categories

            var regrouped = [Name]()

            regrouped.append(categories[0])
            regrouped.append(categories[1])
            regrouped.append(categories[4])
            regrouped.append(categories[6])
            regrouped.append(categories[8])
            regrouped.append(categories[3])
            regrouped.append(categories[7])
            regrouped.append(categories[5])
            regrouped.append(categories[2])

            return regrouped
          }
        }
      }
    }

    return []
  }

}
