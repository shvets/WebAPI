import Foundation
import SwiftyJSON

open class EtvnetAPI: ApiService {
  static let PER_PAGE = 15
  
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
  
  public init(config: Config) {
    super.init(config: config, apiUrl: ApiUrl, userAgent: UserAgent, authUrl: AuthUrl, clientId: ClientId,
               clientSecret: ClientSecret, grantType: GrantType, scope: Scope)
  }
  
  func tryCreateToken(userCode: String, deviceCode: String,
                      activationUrl: String) -> [String: String] {
    print("Register activation code on web site \(activationUrl): \(userCode)")
    
    var result = [String: String]()
    
    var done = false
    
    while !done {
      result = createToken(deviceCode: deviceCode)
      
      done = result["access_token"] != nil
      
      if !done {
        sleep(5)
      }
    }
    
    config.save(result)
    
    return result
  }
  
  public func getChannels(today: Bool = false) -> JSON {
    let path = "video/channels.json"
    
    let url = buildUrl(path: path, params: ["today": String(today) as AnyObject])
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func getArchive(genre: Int? = nil, channelId: Int? = nil, perPage: Int=PER_PAGE, page: Int=1) -> JSON {
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
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func getGenres(parentId: String? = nil, today: Bool=false, channelId: String? = nil, format: String? = nil) -> JSON {
    let path = "video/genres.json"
    let todayString: String? = today ? "yes" : nil
    
    var params = [String: String]()
    params["parent"] = parentId
    params["today"] = todayString
    params["channel"] = channelId
    params["format"] = format
    
    let url = buildUrl(path: path, params: params as [String : AnyObject])
    
    let response = fullRequest(path: url)
    
    // regroup genres
    
    var result = JSON(data: response!)
    
    var data = result["data"]
    
    var genres = [JSON]()
    
    genres.append(data[0])
    genres.append(data[1])
    genres.append(data[5])
    genres.append(data[9])
    
    genres.append(data[7])
    genres.append(data[2])
    genres.append(data[3])
    genres.append(data[4])
    
    genres.append(data[6])
    genres.append(data[8])
    genres.append(data[10])
    genres.append(data[11])
    
    genres.append(data[12])
    //genres.append(data[13])
    genres.append(data[14])
    //genres.append(data[15])
    
    result["data"] = JSON(genres)
    
    return result
  }
  
  public func getGenre(_ genres: JSON, name: String) -> Int? {
    var genre: Int?
    
    for (_, item) in genres["data"] {
      if item["name"].rawString() == name {
        genre = item["id"].intValue
        
        break
      }
    }
    
    return genre
  }
  
  public func getBlockbusters(perPage: Int=PER_PAGE, page: Int=1) -> JSON {
    let genres = getGenres()
    
    let genre = getGenre(genres, name: "Блокбастеры")
    
    return getArchive(genre: genre, perPage: perPage, page: page)
  }
  
  public func getCoolMovies(perPage: Int=PER_PAGE, page: Int=1) -> JSON {
    return getArchive(channelId: 158, perPage: perPage, page: page)
  }
  
  public func search(_ query: String, perPage: Int=PER_PAGE, page: Int=1, dir: String? = nil) -> JSON {
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
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func getNewArrivals(genre: String? = nil, channelId: String? = nil, perPage: Int=PER_PAGE, page: Int=1) -> JSON {
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
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func getHistory(perPage: Int=PER_PAGE, page: Int=1) -> JSON {
    let path = "video/media/history.json"
    
    let url = buildUrl(path: path)
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func getLiveChannelUrl(_ channelId: Int, format: String="mp4", mediaProtocol: String="hls",
                                bitrate: String? = nil, otherServer: String? = nil, offset: String? = nil) -> [String: String] {
    return getUrl(0, format: format, mediaProtocol: mediaProtocol, bitrate: bitrate, otherServer: otherServer,
                  offset: offset, live: true, channelId: channelId, preview: false)
  }
  
  public func getUrl(_ mediaId: Int, format: String="mp4", mediaProtocol: String="hls", bitrate: String? = nil,
                     otherServer: String? = nil, offset: String? = nil, live: Bool=false,
                     channelId: Int? = nil, preview: Bool=false) -> [String: String] {
    var result = [String: String]()
    
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
    let response = fullRequest(path: url)
    let data = JSON(data: response!)
    
    let itemUrl = data["data"]["url"]
    
    if itemUrl != JSON.null {
      result = ["url": itemUrl.rawString()!, "format": newFormat]
      
      if newMediaProtocol != nil {
        result["protocol"] = newMediaProtocol
      }
    }
    
    return result
  }

  public func getChildren(_ mediaId: Int, perPage: Int=PER_PAGE, page: Int=1, dir: String?=nil) -> JSON {
    let path = "video/media/\(mediaId)/children.json"
    
    var params = [String: String]()
    params["per_page"] = String(perPage)
    params["page"] = String(page)
    params["dir"] = dir
    
    let url = buildUrl(path: path, params: params as [String : AnyObject])
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func getBookmarks(folder: String? = nil, perPage: Int=PER_PAGE, page: Int=1) -> JSON {
    let params = ["per_page": String(perPage), "page": String(page)]
    
    var path: String
    
    if folder != nil {
      path = "video/bookmarks/folders/\(folder!)/items.json"
    }
    else {
      path = "video/bookmarks/items.json"
    }
    
    let url = buildUrl(path: path, params: params as [String : AnyObject])
    
    let response = fullRequest(path: url)
    
    return JSON(data: (response != nil) ? response! : Data())
  }
  
  public func getFolders(perPage: Int=PER_PAGE) -> JSON {
    let url = buildUrl(path: "video/bookmarks/folders.json")
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func getBookmark(id: String) -> JSON {
    let url = buildUrl(path: "video/bookmarks/items/\(id).json")
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func addBookmark(id: Int) -> JSON {
    let url = buildUrl(path: "video/bookmarks/items/\(id).json")
    
    let response = fullRequest(path: url, method: .post)
    
    return JSON(data: response!)
  }
  
  public func removeBookmark(id: Int) -> JSON {
    let url = buildUrl(path: "video/bookmarks/items/\(id).json")

    let response = fullRequest(path: url, method: .delete)
    
    return JSON(data: response!)
  }
  
  public func getTopicItems(_ id: String="best", perPage: Int=PER_PAGE, page: Int=1) -> JSON {
    var params = [String: String]()
    params["per_page"] = String(perPage)
    params["page"] = String(page)
    
    let url = buildUrl(path: "video/media/\(id).json", params: params as [String : AnyObject])
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func getLiveChannels(favoriteOnly: Bool=false, offset: String? = nil, category: Int=0) -> JSON {
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
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func addFavoriteChannel(id: Int) -> JSON {
    let url = buildUrl(path: "video/live/\(id)/favorite.json")
    
    let response = fullRequest(path: url, method: .post)

    return JSON(data: response!)
  }

  public func removeFavoriteChannel(id: Int) -> JSON {
    let url = buildUrl(path: "video/live/\(id)/favorite.json")
    
    let response = fullRequest(path: url, method: .delete)
    
    return JSON(data: response!)
  }
  
  public func getLiveSchedule(liveChannelId: String, date: Date = Date()) -> JSON {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd@nbsp;HH:mm"
    
    let dateString = dateFormatter.string(from: date)

    let params = ["date": dateString]
    
    let path = "video/live/schedule/\(liveChannelId).json"
    
    let url = buildUrl(path: path, params: params as [String : AnyObject])
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func getLiveCategories() -> JSON {
    let url = buildUrl(path: "video/live/category.json")
    
    let response = fullRequest(path: url)
    
    var result = JSON(data: response!)
    
    // regroup categories
    
    var data = result["data"]
    
    var categories = [JSON]()

    categories.append(data[0])
    categories.append(data[1])
    categories.append(data[4])
    categories.append(data[6])
    categories.append(data[8])
    categories.append(data[3])
    categories.append(data[7])
    categories.append(data[5])
    categories.append(data[2])
    
    result["data"] = JSON(categories)
    
    return result
  }
  
}
