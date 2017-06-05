import Foundation
import SwiftyJSON

open class MuzArbuzAPI: HttpService {
  static let SiteUrl = "https://muzarbuz.com"
  static let ApiUrl = "\(SiteUrl)/api/v1"
  let UserAgent = "MuzArbuz User Agent"

  let ValidParameters = ["album", "artists", "collection__id", "parent__id", "genre__in"]

  let CyrillicLetters = ["А", "Б", "В", "Г", "Д", "Е", "Ё", "Ж", "З", "И", "Й", "К", "Л", "М", "Н", "О", "П", "Р", "С",
                         "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш", "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", "Я"]

  let LatinLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
                      "T", "U", "V", "W", "X", "Y", "Z"]

  func getAlbums(_ params: [String: String]=[:]) throws -> JSON {
    let url = buildUrl(path: MuzArbuzAPI.ApiUrl + "/album", params: params as [String : AnyObject])

    print(url)

    return try apiRequest(url)
  }

  func getTracks(_ params: [String: String]=[:]) throws -> JSON {
    let url = buildUrl(path: MuzArbuzAPI.ApiUrl + "/audio_track", params: params as [String : AnyObject])

    return try apiRequest(url)
  }

  func getArtists(_ params: [String: String]=[:]) throws -> JSON {
    let url = buildUrl(path: MuzArbuzAPI.ApiUrl + "/artist", params: params as [String : AnyObject])

    return try apiRequest(url)
  }

  func getArtistAnnotated(_ params: [String: String]=[:]) throws -> JSON {
    let url = buildUrl(path: MuzArbuzAPI.ApiUrl + "/artist_annotated", params: params as [String : AnyObject])

    return try apiRequest(url)
  }

  func getCollections(_ params: [String: String]=[:]) throws -> JSON {
    let url = buildUrl(path: MuzArbuzAPI.ApiUrl + "/collection", params: params as [String : AnyObject])

    return try apiRequest(url)
  }

  func getGenres(_ params: [String: String]=[:]) throws -> JSON {
    let url = buildUrl(path: MuzArbuzAPI.ApiUrl + "/genre", params: params as [String : AnyObject])

    return try apiRequest(url)
  }

  func search(query: String) throws -> [String: Any] {
    var params = [String: String]()
    params["q"] = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    return [
      "collection": try searchCollection(params: params),
      "artist_annotated": try searchArtistAnnotated(params: params),
      "album": try searchAlbum(params: params),
      "audio_track": try searchAudioTrack(params: params)
    ]
  }

  func searchCollection(params: [String: String]) throws -> JSON {
    let url = buildUrl(path: MuzArbuzAPI.ApiUrl + "/collection/search/", params: params as [String: AnyObject])

    return try apiRequest(url)
  }

  func searchArtistAnnotated(params: [String: String]) throws -> JSON {
    let url = buildUrl(path: MuzArbuzAPI.ApiUrl + "/artist_annotated/search/", params: params as [String: AnyObject])

    return try apiRequest(url)
  }

  func searchAlbum(params: [String: String]) throws -> JSON {
    let url = buildUrl(path: MuzArbuzAPI.ApiUrl + "/album/search/", params: params as [String: AnyObject])

    return try apiRequest(url)
  }

  func searchAudioTrack(params: [String: String]) throws -> JSON {
    let url = buildUrl(path: MuzArbuzAPI.ApiUrl + "/audio_track/search/", params: params as [String: AnyObject])

    return try apiRequest(url)
  }

//def filter_request_params(self, params):
//return dict((key, value) for key, value in params.iteritems() if key in self.VALID_PARAMETERS)
//

  func add_pagination_to_response(response: [String: String], page: Int, per_page: Int) {
  //  pages = float(response['meta']['total_count']) / float(per_page)
  //
  //if pages > int(pages):
  //pages = int(pages) + 1
  //else:
  //pages = int(pages)
  //
  //response['data'] = {'pagination': {
  //  'page': page,
  //  'pages': pages,
  //  'has_next': page < pages,
  //  'has_previous': page > 1
  //}}
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
