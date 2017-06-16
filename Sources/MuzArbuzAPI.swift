import Foundation
import SwiftyJSON

public typealias Parameters = [String: Any]

open class MuzArbuzAPI: HttpService {
  public static let SiteUrl = "https://muzarbuz.com"
  static let ApiUrl = "\(SiteUrl)/api/v1"
  let UserAgent = "MuzArbuz User Agent"

  let ValidParameters = ["album", "artists", "collection__id", "parent__id", "genre__in"]

  let CyrillicLetters = ["А", "Б", "В", "Г", "Д", "Е", "Ё", "Ж", "З", "И", "Й", "К", "Л", "М", "Н", "О", "П", "Р", "С",
                         "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш", "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", "Я"]

  let LatinLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
                      "T", "U", "V", "W", "X", "Y", "Z"]

  public func getAlbums(params: [String: String]=[:], pageSize: Int=20, page: Int=1) throws -> [String: Any] {
    return try queryData(params: params, path: "/album", page: page, pageSize: pageSize) { objects in
      var data = [Any]()

      for (_, object) in objects {
        let id = object["id"].stringValue
        let name = object["title"].stringValue
        let thumb = MuzArbuzAPI.SiteUrl + object["thumbnail"].stringValue

        if object["album"] == JSON.null && object["is_seria"] != JSON.null {
          data.append(["type": "double_album", "id": id, "parent__id": id, "name": name, "thumb": thumb])
        }
        else {
          data.append(["type": "album", "id": id, "name": name, "thumb": thumb])
        }
      }

      return data
    }
  }

  public func getTracks(params: [String: String]=[:], pageSize: Int=20, page: Int=1) throws -> [String: Any] {
    return try queryData(params: params, path: "/audio_track", page: page, pageSize: pageSize) { objects in
      var data = [Any]()

      for (_, object) in objects {
        let name = object["title"].stringValue
        let file = object["file"].stringValue
        let thumb = MuzArbuzAPI.SiteUrl + object["album"]["thumbnail"].stringValue
        var artist = ""

        if object["album"] != JSON.null && object["album"]["artist"] != JSON.null {
          artist = object["album"]["artist"]["title"].stringValue
        }

        data.append(["type": "track", "id": MuzArbuzAPI.SiteUrl + file, "name": name, "thumb": thumb, "artist": artist])
      }

      return data
    }
  }

  public func getArtists(params: [String: String]=[:], pageSize: Int=20, page: Int=1) throws -> [String: Any] {
    return try queryData(params: params, path: "/artist", page: page, pageSize: pageSize) { objects in
      var data = [Any]()

      for (_, object) in objects {
        let id = object["id"].stringValue
        let name = object["title"].stringValue
        let thumb = MuzArbuzAPI.SiteUrl + object["thumbnail"].stringValue

        data.append(["type": "artist", "id": id, "name": name, "thumb": thumb])
      }

      return data
    }
  }

  public func getArtistAnnotated(params: [String: String]=[:], pageSize: Int=20, page: Int=1) throws -> [String: Any] {
    return try queryData(params: params, path: "/artist_annotated", page: page, pageSize: pageSize) { objects in
      var data = [Any]()

      return data
    }
  }

  public func getCollections(params: [String: String]=[:], pageSize: Int=20, page: Int=1) throws -> [String: Any] {
    return try queryData(params: params, path: "/collection", page: page, pageSize: pageSize) { objects in
      var data = [Any]()

      for (_, object) in objects {
        let id = object["id"].stringValue
        let name = object["title"].stringValue
        let thumb = MuzArbuzAPI.SiteUrl + object["thumbnail"].stringValue

        data.append(["type": "collection", "id": id, "name": name, "thumb": thumb])
      }

      return data
    }
  }

  func getGenres(params: [String: String]=[:], pageSize: Int=20, page: Int=1) throws -> [String: Any] {
    return try queryData(params: params, path: "/genre", page: page, pageSize: pageSize) { objects in
      var data = [Any]()

      for (_, object) in objects {
        let id = object["id"].stringValue
        let name = object["title"].stringValue
        let thumb = MuzArbuzAPI.SiteUrl + object["thumbnail"].stringValue

        data.append(["type": "genre", "id": id, "name": name, "thumb": thumb])
      }

      return data
    }
  }

  public func search(query: String, pageSize: Int=20, page: Int=1) throws -> [String: Any] {
    var params = [String: String]()
    params["q"] = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    return [
      "collection": try searchCollection(params: params, pageSize: pageSize, page: page),
      "artist_annotated": try searchArtistAnnotated(params: params, pageSize: pageSize, page: page),
      "album": try searchAlbum(params: params, pageSize: pageSize, page: page),
      "audio_track": try searchAudioTrack(params: params, pageSize: pageSize, page: page)
    ]
  }

  func searchCollection(params: [String: String], pageSize: Int, page: Int) throws -> [String: Any] {
    return try queryData(params: params, path: "/collection/search/", page: page, pageSize: pageSize) { objects in
      var data = [Any]()

      return data
    }
  }

  func searchArtistAnnotated(params: [String: String], pageSize: Int, page: Int) throws -> [String: Any] {
    return try queryData(params: params, path: "/artist_annotated/search/", page: page, pageSize: pageSize) { objects in
      var data = [Any]()

      return data
    }
  }

  func searchAlbum(params: [String: String], pageSize: Int, page: Int) throws -> [String: Any] {
    return try queryData(params: params, path: "/album/search/", page: page, pageSize: pageSize) { objects in
      var data = [Any]()

      return data
    }
  }

  func searchAudioTrack(params: [String: String], pageSize: Int, page: Int) throws -> [String: Any] {
    return try queryData(params: params, path: "/audio_track/search/", page: page, pageSize: pageSize) { objects in
      var data = [Any]()

      return data
    }
  }

  private func queryData(params: [String: String], path: String, page: Int, pageSize: Int,
                         itemsBuilder: (JSON) -> [Any]) throws -> [String: Any] {
    let offset = (page-1)*pageSize

    var newParams = Parameters()

    for (key, value) in params {
      newParams[key] = value
    }

    newParams["limit"] = "\(pageSize)"
    newParams["offset"] = "\(offset)"

    let url = buildUrl(path: MuzArbuzAPI.ApiUrl + path, params: newParams as [String : AnyObject])

    let response = try apiRequest(url)

    if response != JSON.null {
      let items = itemsBuilder(response["objects"])
      let paginationData = try buildPaginationData(response: response, page: page, pageSize: pageSize)

      return ["items": items, "pagination": paginationData]
    }
    else {
      return ["items": [], "pagination": []]
    }
  }

  func buildPaginationData(response: JSON, page: Int, pageSize: Int) throws -> [String: Any] {
    let pages = Int(response["meta"]["total_count"].stringValue)! / pageSize

    return [
      "pagination": [
        "page": page,
        "pages": pages,
        "has_next": page < pages,
        "has_previous": page > 1
      ]
    ]
  }

  func apiRequest(_ url: String) throws -> JSON {
    var headers: [String: String] = [:]

    headers["User-agent"] = UserAgent
    headers["Content-Type"] = "application/json"

    if let data = fetchData(url, headers: headers) {
      return JSON(data: data)
    }
    else {
      return JSON.null
    }
  }

}
