import Foundation

public typealias Parameters = [String: Any]

open class MuzArbuzAPI: HttpService {
  public static let SiteUrl = "https://muzarbuz.com"
  static let ApiUrl = "\(SiteUrl)/api/v1"
  let UserAgent = "MuzArbuz User Agent"

  let ValidParameters = ["album", "artists", "collection__id", "parent__id", "genre__in"]

  public static let CyrillicLetters = ["А", "Б", "В", "Г", "Д", "Е", "Ё", "Ж", "З", "И", "Й", "К", "Л", "М", "Н", "О", "П", "Р", "С",
                         "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш", "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", "Я"]

  public static let LatinLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
                      "T", "U", "V", "W", "X", "Y", "Z"]

//  public func getAlbums(params: [String: String]=[:], pageSize: Int=20, page: Int=1) throws -> [String: Any] {
//    return try queryData(params: params, path: "/album", page: page, pageSize: pageSize) { objects in
//      var data = [Any]()
//
//      for (_, object) in objects {
//        data.append(buildAlbum(object))
//      }
//
//      return data
//    }
//  }
//
//  public func getTracks(params: [String: String]=[:], pageSize: Int=20, page: Int=1) throws -> [String: Any] {
//    return try queryData(params: params, path: "/audio_track", page: page, pageSize: pageSize) { objects in
//      var data = [Any]()
//
//      for (_, object) in objects {
//        data.append(buildTrack(object))
//      }
//
//      return data
//    }
//  }
//
//  public func getArtists(params: [String: String]=[:], pageSize: Int=20, page: Int=1) throws -> [String: Any] {
//    return try queryData(params: params, path: "/artist", page: page, pageSize: pageSize) { objects in
//      var data = [Any]()
//
//      for (_, object) in objects {
//        data.append(buildArtist(object))
//      }
//
//      return data
//    }
//  }
//
//  public func getArtistAnnotated(params: [String: String]=[:], pageSize: Int=20, page: Int=1) throws -> [String: Any] {
//    return try queryData(params: params, path: "/artist_annotated", page: page, pageSize: pageSize) { objects in
//      var data = [Any]()
//
//      for (_, object) in objects {
//        data.append(buildArtist(object))
//      }
//
//      return data
//    }
//  }
//
//  public func getCollections(params: [String: String]=[:], pageSize: Int=20, page: Int=1) throws -> [String: Any] {
//    return try queryData(params: params, path: "/collection", page: page, pageSize: pageSize) { objects in
//      var data = [Any]()
//
//      for (_, object) in objects {
//        data.append(buildCollection(object))
//      }
//
//      return data
//    }
//  }
//
//  public func getGenres(params: [String: String]=[:], pageSize: Int=20, page: Int=1) throws -> [String: Any] {
//    return try queryData(params: params, path: "/genre", page: page, pageSize: pageSize) { objects in
//      var data = [Any]()
//
//      for (_, object) in objects {
//        let id = object["id"].stringValue
//        let name = object["title"].stringValue
//        let thumb = MuzArbuzAPI.SiteUrl + object["thumbnail"].stringValue
//
//        data.append(["type": "genre", "id": id, "name": name, "thumb": thumb])
//      }
//
//      return data
//    }
//  }
//
//  public func search(_ query: String, pageSize: Int=20, page: Int=1) throws -> [String: Any] {
//    var params = [String: String]()
//    params["q"] = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
//
//    return [
//      "collection": try searchCollection(params, pageSize: pageSize, page: page),
//      "artist_annotated": try searchArtistAnnotated(params, pageSize: pageSize, page: page),
//      "album": try searchAlbum(params, pageSize: pageSize, page: page),
//      "audio_track": try searchAudioTrack(params, pageSize: pageSize, page: page)
//    ]
//  }
//
//  public func searchCollection(_ params: [String: String], pageSize: Int, page: Int) throws -> [String: Any] {
//    return try queryData(params: params, path: "/collection/search/", page: page, pageSize: pageSize) { objects in
//      var data = [Any]()
//
//      for (_, object) in objects {
//        data.append(buildCollection(object))
//      }
//
//      return data
//    }
//  }
//
//  public func searchArtistAnnotated(_ params: [String: String], pageSize: Int, page: Int) throws -> [String: Any] {
//    return try queryData(params: params, path: "/artist_annotated/search/", page: page, pageSize: pageSize) { objects in
//      var data = [Any]()
//
//      for (_, object) in objects {
//        data.append(buildArtist(object))
//      }
//
//      return data
//    }
//  }
//
//  public func searchAlbum(_ params: [String: String], pageSize: Int, page: Int) throws -> [String: Any] {
//    return try queryData(params: params, path: "/album/search/", page: page, pageSize: pageSize) { objects in
//      var data = [Any]()
//
//      for (_, object) in objects {
//        data.append(buildAlbum(object))
//      }
//
//      return data
//    }
//  }
//
//  public func searchAudioTrack(_ params: [String: String], pageSize: Int, page: Int) throws -> [String: Any] {
//    return try queryData(params: params, path: "/audio_track/search/", page: page, pageSize: pageSize) { objects in
//      var data = [Any]()
//
//      for (_, object) in objects {
//        data.append(buildTrack(object))
//      }
//
//      return data
//    }
//  }
//
//  private func queryData(params: [String: String], path: String, page: Int, pageSize: Int,
//                         itemsBuilder: (JSON) -> [Any]) throws -> [String: Any] {
//    let offset = (page-1)*pageSize
//
//    var newParams = Parameters()
//
//    for (key, value) in params {
//      newParams[key] = value
//    }
//
//    newParams["limit"] = "\(pageSize)"
//    newParams["offset"] = "\(offset)"
//
//    let url = buildUrl(path: MuzArbuzAPI.ApiUrl + path, params: newParams as [String : AnyObject])
//
//    let response = try apiRequest(url)
//
//    if response != JSON.null {
//      let items = itemsBuilder(response["objects"])
//      let paginationData = try buildPaginationData(response: response, page: page, pageSize: pageSize)
//
//      return ["items": items, "pagination": paginationData]
//    }
//    else {
//      return ["items": [], "pagination": []]
//    }
//  }
//
//  private func buildAlbum(_ data: JSON) -> [String: String] {
//    var result: [String: String] = [:]
//
//    result["id"] = data["id"].stringValue
//    result["name"] = data["title"].stringValue
//    result["thumb"] = MuzArbuzAPI.SiteUrl + data["thumbnail"].stringValue
//
//    if data["album"] == JSON.null && data["is_seria"] != JSON.null && data["is_seria"].boolValue == true {
//      result["type"] = "double_album"
//      result["parent__id"] = "id"
//    }
//    else {
//      result["type"] = "album"
//    }
//
//    return result
//  }
//
//  private func buildTrack(_ data: JSON) -> [String: String] {
//    var result: [String: String] = [:]
//
//    let file = data["file"].stringValue
//
//    result["type"] = "track"
//    result["name"] = data["title"].stringValue
//    result["thumb"] = MuzArbuzAPI.SiteUrl + data["thumbnail"].stringValue
//    result["id"] = MuzArbuzAPI.SiteUrl + file
//
//    var artist = ""
//
//    if data["album"] != JSON.null && data["album"]["artist"] != JSON.null {
//      artist = data["album"]["artist"]["title"].stringValue
//    }
//
//    result["artist"] = artist
//
//    return result
//  }
//
//  private func buildArtist(_ data: JSON) -> [String: String] {
//    var result: [String: String] = [:]
//
//    result["type"] = "artist"
//    result["id"] = data["id"].stringValue
//    result["name"] = data["title"].stringValue
//    result["thumb"] = MuzArbuzAPI.SiteUrl + data["thumbnail"].stringValue
//
//    return result
//  }
//
//  private func buildCollection(_ data: JSON) -> [String: String] {
//    var result: [String: String] = [:]
//
//    result["type"] = "collection"
//    result["id"] = data["id"].stringValue
//    result["name"] = data["title"].stringValue
//    result["thumb"] = MuzArbuzAPI.SiteUrl + data["thumbnail"].stringValue
//
//    return result
//  }
//
//  private func buildPaginationData(response: JSON, page: Int, pageSize: Int) throws -> [String: Any] {
//    let pages = Int(response["meta"]["total_count"].stringValue)! / pageSize
//
//    return [
//      "pagination": [
//        "page": page,
//        "pages": pages,
//        "has_next": page < pages,
//        "has_previous": page > 1
//      ]
//    ]
//  }
//
//  private func apiRequest(_ url: String) throws -> JSON {
//    var headers: [String: String] = [:]
//
//    headers["User-agent"] = UserAgent
//    headers["Content-Type"] = "application/json"
//
//    if let data = fetchData(url, headers: headers) {
//      return JSON(data: data)
//    }
//    else {
//      return JSON.null
//    }
//  }

}
