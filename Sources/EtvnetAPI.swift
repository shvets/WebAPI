import Foundation
import SwiftyJSON

open class EtvnetAPI : ApiService {
  static let PER_PAGE = 15
  
  let API_URL = "https://secure.etvnet.com/api/v3.0/"
  let USER_AGENT = "Etvnet User Agent"
  
  let AUTH_URL = "https://accounts.etvnet.com/auth/oauth/"
  let CLIENT_ID = "a332b9d61df7254dffdc81a260373f25592c94c9"
  let CLIENT_SECRET = "744a52aff20ec13f53bcfd705fc4b79195265497"
  
  let SCOPE = [
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
  
  let GRANT_TYPE = "http://oauth.net/grant_type/device/1.0"
  
  let TIME_SHIFT = [
    "0": 0,  // Moscow
    "1": 2,  // Berlin
    "2": 3,  // London
    "3": 8,  // New York
    "4": 9,  // Chicago
    "5": 10, // Denver
    "6": 11  // Los Angeles
  ]
  
  public static let TOPICS = ["etvslider/main", "newmedias", "best", "top", "newest", "now_watched", "recommend"]
  
  public init(config: Config) {
    super.init(config: config, api_url: API_URL, user_agent: USER_AGENT, auth_url: AUTH_URL, client_id: CLIENT_ID,
               client_secret: CLIENT_SECRET, grant_type: GRANT_TYPE, scope: SCOPE)
  }
  
  func tryCreateToken(user_code: String, device_code: String,
                      activation_url: String) -> [String: String] {
    print("Register activation code on web site \(activation_url): \(user_code)")
    
    var result: [String: String] = [:]
    
    var done = false
    
    while !done {
      result = createToken(device_code: device_code)
      
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
  
  public func getArchive(genre: Int? = nil, channel_id: Int? = nil, per_page: Int=PER_PAGE, page: Int=1) -> JSON {
    var path: String
    
    if channel_id != nil && genre != nil {
      path = "video/media/channel/\(channel_id!)/archive/\(genre!).json"
    }
    else if genre != nil {
      path = "video/media/archive/\(genre!).json"
    }
    else if channel_id != nil {
      path = "video/media/channel/\(channel_id!)/archive.json"
    }
    else {
      path = "video/media/archive.json"
    }
    
    var params = [String: String]()
    params["per_page"] = String(per_page)
    params["page"] = String(page)
    
    let url = buildUrl(path: path, params: params as [String : AnyObject])
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func getGenres(parent_id: String? = nil, today: Bool=false, channel_id: String? = nil, format: String? = nil) -> JSON {
    let path = "video/genres.json"
    let todayString: String? = today ? "yes" : nil
    
    var params = [String: String]()
    params["parent"] = parent_id
    params["today"] = todayString
    params["channel"] = channel_id
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
  
  public func getBlockbusters(per_page: Int=PER_PAGE, page: Int=1) -> JSON {
    let genres = getGenres()
    
    let genre = getGenre(genres, name: "Блокбастеры")
    
    return getArchive(genre: genre, per_page: per_page, page: page)
  }
  
  public func getCoolMovies(per_page: Int=PER_PAGE, page: Int=1) -> JSON {
    return getArchive(channel_id: 158, per_page: per_page, page: page)
  }
  
  public func search(query: String, per_page: Int=PER_PAGE, page: Int=1, dir: String? = nil) -> JSON {
    var newDir = dir
    
    if newDir == nil {
      newDir = "desc"
    }
    
    let path = "video/media/search.json"
    
    var params = [String: String]()
    params["q"] = query
    params["per_page"] = String(per_page)
    params["page"] = String(page)
    params["dir"] = dir
    
    let url = buildUrl(path: path, params: params as [String : AnyObject])
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func getNewArrivals(genre: String? = nil, channel_id: String? = nil, per_page: Int=PER_PAGE, page: Int=1) -> JSON {
    var path: String
    
    if channel_id != nil && genre != nil {
      path = "video/media/channel/\(channel_id)/new_arrivals/\(genre).json"
    }
    else if genre != nil {
      path = "video/media/new_arrivals/\(genre).json"
    }
    else if channel_id != nil {
      path = "video/media/channel/\(channel_id)/new_arrivals.json"
    }
    else {
      path = "video/media/new_arrivals.json"
    }
    
    var params = [String: String]()
    params["per_page"] = String(per_page)
    params["page"] = String(page)
    
    let url = buildUrl(path: path, params: params as [String : AnyObject])
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func getHistory(per_page: Int=PER_PAGE, page: Int=1) -> JSON {
    let path = "video/media/history.json"
    
    let url = buildUrl(path: path)
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func getLiveChannelUrl(_ channel_id: Int, format: String="mp4", mediaProtocol: String="hls",
                                bitrate: String? = nil, other_server: String? = nil, offset: String? = nil) -> [String: String] {
    return getUrl(0, format: format, mediaProtocol: mediaProtocol, bitrate: bitrate, other_server: other_server,
                  offset: offset, live: true, channel_id: channel_id, preview: false)
  }
  
  public func getUrl(_ media_id: Int, format: String="mp4", mediaProtocol: String="hls", bitrate: String? = nil,
                     other_server: String? = nil, offset: String? = nil, live: Bool=false,
                     channel_id: Int? = nil, preview: Bool=false) -> [String: String] {
    var result = [String: String]()
    
    var newFormat = format
    var newMediaProtocol: String? = mediaProtocol
    
    if format == "zixi" {
      newFormat = "mp4"
    }
    
    let path: String
    var params: [String: String]
    
    if live {
      path = "video/live/watch/\(channel_id!).json"
      
      params = ["format": newFormat]
      
      if offset != nil {
        params["offset"] = offset!
      }
      
      if bitrate != nil {
        params["bitrate"] = bitrate!
      }
      
      if other_server != nil {
        params["other_server"] = other_server!
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
      
      path = "video/media/\(media_id)/\(link_type).json"
      
      params = ["format": newFormat]
      
      if newMediaProtocol != nil {
        params["protocol"] = newMediaProtocol!
      }
      
      if bitrate != nil {
        params["bitrate"] = bitrate!
      }
      
      if other_server != nil {
        params["other_server"] = other_server!
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

  public func getChildren(_ media_id: Int, per_page: Int=PER_PAGE, page: Int=1, dir: String?=nil) -> JSON {
    let path = "video/media/\(media_id)/children.json"
    
    var params = [String: String]()
    params["per_page"] = String(per_page)
    params["page"] = String(page)
    params["dir"] = dir
    
    let url = buildUrl(path: path, params: params as [String : AnyObject])
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func getBookmarks(folder: String? = nil, per_page: Int=PER_PAGE, page: Int=1) -> JSON {
    let params = ["per_page": String(per_page), "page": String(page)]
    
    var path: String
    
    if folder != nil {
      path = "video/bookmarks/folders/\(folder)/items.json"
    }
    else {
      path = "video/bookmarks/items.json"
    }
    
    let url = buildUrl(path: path, params: params as [String : AnyObject])
    
    let response = fullRequest(path: url)
    
    return JSON(data: (response != nil) ? response! : Data())
  }
  
  public func getFolders(per_page: Int=PER_PAGE) -> JSON {
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
    
    let response = fullRequest(path: url, method: "post")
    
    return JSON(data: response!)
  }
  
  public func removeBookmark(id: Int) -> JSON {
    let url = buildUrl(path: "video/bookmarks/items/\(id).json")

    let response = fullRequest(path: url, method: "delete")
    
    return JSON(data: response!)
  }
  
  public func getTopicItems(_ id: String="best", per_page: Int=PER_PAGE, page: Int=1) -> JSON {
    var params = [String: String]()
    params["per_page"] = String(per_page)
    params["page"] = String(page)
    
    let url = buildUrl(path: "video/media/\(id).json", params: params as [String : AnyObject])
    
    let response = fullRequest(path: url)
    
    return JSON(data: response!)
  }
  
  public func getLiveChannels(favorite_only: Bool=false, offset: String? = nil, category: Int=0) -> JSON {
    let format = "mp4"
    
    var params = ["format": format, "allowed_only": String(1), "favorite_only": String(favorite_only)]
    
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
    
    let response = fullRequest(path: url, method: "post")

    return JSON(data: response!)
  }

  public func removeFavoriteChannel(id: Int) -> JSON {
    let url = buildUrl(path: "video/live/\(id)/favorite.json")
    
    let response = fullRequest(path: url, method: "delete")
    
    return JSON(data: response!)
  }
  
  public func getLiveSchedule(live_channel_id: String, date: Date = Date()) -> JSON {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd@nbsp;HH:mm"
    
    let dateString = dateFormatter.string(from: date)
    
    
    let params = ["date": dateString]
    
    let path = "video/live/schedule/\(live_channel_id).json"
    
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

