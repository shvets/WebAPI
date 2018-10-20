import Foundation

import SwiftSoup
import Alamofire

open class KinoGoAPI: HttpService {
  public static let SiteUrl = "https://kinogo.by"
  let UserAgent = "KinoGo User Agent"

  public func getDocument(_ url: String) throws -> Document? {
    return try fetchDocument(url, headers: getHeaders(), encoding: .windowsCP1251)
  }

  public func searchDocument(_ url: String, parameters: [String: String]) throws -> Document? {
    return try fetchDocument(url, headers: getHeaders(KinoGoAPI.SiteUrl + "/"), parameters: parameters,
      method: .post, encoding: .windowsCP1251)
  }

  public func available() throws -> Bool {
    if let document = try getDocument(KinoGoAPI.SiteUrl) {
      return try document.select("div[class=wrapper]").size() > 0
    }
    else {
      return false
    }
  }

  public func getCookie(url: String) -> String? {
    let response: DataResponse<Data>? = httpRequest(url)

    return response?.response?.allHeaderFields["Set-Cookie"] as? String
  }

  func getPagePath(_ path: String, page: Int=1) -> String {
    if page == 1 {
      return path
    }
    else {
      return "\(path)page/\(page)/"
    }
  }

  public func getCategoriesByTheme() throws -> [[String: String]] {
    return try getAllCategories()["Категории"]!
  }

  public func getCategoriesByYear() throws -> [[String: String]] {
    return try getAllCategories()["По году"]!
  }

  public func getCategoriesByCountry() throws -> [[String: String]] {
    return try getAllCategories()["По странам"]!
  }

  public func getCategoriesBySerie() throws -> [[String: String]] {
    return try getAllCategories()["Сериалы"]!
  }

  public func getAllCategories() throws -> [String: [[String: String]]] {
    var data = [String: [[String: String]]]()

    if let document = try getDocument(KinoGoAPI.SiteUrl) {
      let items = try document.select("div[class=miniblock] div[class=mini]")

      for item: Element in items.array() {
        let groupName = try item.select("i").text()

        var list = [[String: String]]()

        let links = try item.select("a")

        for item2: Element in links.array() {
          let href = try item2.attr("href")
          var name = try item2.text()

          if let nextSibling = item2.nextSibling(),
            let firstSibling = nextSibling.getChildNodes().first as? TextNode {
              name += " \(firstSibling.text())"
          }

          list.append(["id": KinoGoAPI.SiteUrl + href, "name": name])
        }

        data[groupName] = list
      }
    }

    return data
  }

  public func getAllMovies(page: Int=1) throws -> [String: Any] {
    return try getMovies("/", page: page)
  }

  public func getPremierMovies(page: Int=1) throws -> [String: Any] {
    return try getMovies("/film/premiere/", page: page)
  }

  public func getLastMovies(page: Int=1) throws -> [String: Any] {
    return try getMovies("/film/", page: page)
  }

  public func getAllSeries(page: Int=1) throws -> [String: Any] {
    let result = try getMovies("/serial/", page: page, serie: true)

    return ["pagination": result["pagination"] as Any, "movies": try sanitizeNames(result["movies"] as! [Any])]
  }

  private func sanitizeNames(_ movies: Any) throws -> [Any] {
    var newMovies = [Any]()

    for var movie in movies as! [[String: String]] {
      let pattern = "(\\s*\\(\\d{1,2}-\\d{1,2}\\s*(С|с)езон\\))"

      let regex = try NSRegularExpression(pattern: pattern)

      if let name = movie["name"] {
        let correctedName = regex.stringByReplacingMatches(in: name, options: [], range: NSMakeRange(0, name.count), withTemplate: "")

        movie["name"] = correctedName

        newMovies.append(movie)
      }
    }

    return newMovies
  }

  public func getAnimations(page: Int=1) throws -> [String: Any] {
    return try getMovies("/mult/", page: page)
  }

  public func getAnime(page: Int=1) throws -> [String: Any] {
    return try getMovies("/anime/", page: page)
  }

  public func getTvShows(page: Int=1) throws -> [String: Any] {
    let result = try getMovies("/tv/", page: page, serie: true)

    return ["pagination": result["pagination"] as Any, "movies": try sanitizeNames(result["movies"] as! [Any])]
  }

  public func getMoviesByYear(year: Int, page: Int=1) throws -> [String: Any] {
    return try getMovies("/tag/\(year)", page: page)
  }

  public func getMovies(_ path: String, page: Int=1, serie: Bool=false) throws -> [String: Any] {
    var data = [Any]()
    var paginationData: ItemsList = [:]

    let pagePath = getPagePath(path, page: page)

    if let document = try getDocument(KinoGoAPI.SiteUrl + pagePath) {
      let items = try document.select("div[id=dle-content] div[class=shortstory]")

      for item: Element in items.array() {
        let href = try item.select("div[class=shortstorytitle] h2 a").attr("href")
        let name = try item.select("div[class=shortstorytitle] h2 a").text()
        let thumb = try item.select("div[class=shortimg] a img").first()!.attr("src")

        let type = serie ? "serie" : "movie";

        data.append(["id": href, "name": name, "thumb": KinoGoAPI.SiteUrl + thumb, "type": type])
      }

      if items.size() > 0 {
        paginationData = try extractPaginationData(document, page: page)
      }
    }

    return ["movies": data, "pagination": paginationData]
  }

  public func getUrls(_ path: String) throws -> [String] {
    var urls: [String] = []

    if let document = try getDocument(path) {
      let items = try document.select("script")

      for item: Element in items.array() {
        let text = try item.html()

        if !text.isEmpty {
          let index1 = text.find("\"file\"  :")

          if let startIndex = index1 {
            let text2 = String(text[startIndex..<text.endIndex])

            let text3 = text2

            //.replacingOccurrences(of: "[480,720]", with: "720")

            let index2 = text3.find("\"bgcolor\"")

            if let endIndex = index2 {
              let text4 = text3[text.index(text3.startIndex, offsetBy: 11) ..< endIndex]

              let text5 = text4.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines)

              let text6 = String(text5[text5.startIndex ..< text5.index(text5.endIndex, offsetBy: -2)])

              urls = text6.components(separatedBy: ",")

              break
            }
          }
        }
      }
    }

    var found720 = false

    for url in urls {
      if url.find("720.mp4") != nil {
        found720 = true
      }
    }

    if !found720 && urls.count > 0 {
      urls[urls.count-1] = urls[urls.count-1].replacingOccurrences(of: "480", with: "720")
    }

    return urls.reversed()
  }

//  public func getSeasonPlaylistUrl(_ path: String) throws -> String {
//    var url = ""
//
//    if let document = try getDocument(path) {
//      let items = try document.select("script")
//
//      for item: Element in items.array() {
//        let text = try item.html()
//
//        if !text.isEmpty {
//          let index1 = text.find("pl:")
//
//          if let startIndex = index1 {
//            let text2 = String(String(text[startIndex ..< text.endIndex]))
//
//            let index2 = text2.find("\",st:")
//
//            if let endIndex = index2 {
//              url = String(text2[text2.index(text2.startIndex, offsetBy:4) ..< endIndex])
//
//              break
//            }
//          }
//        }
//      }
//    }
//
//    return url
//  }

  public func search(_ query: String, page: Int=1, perPage: Int=10) throws -> [String: Any] {
    var data = [Any]()
    var paginationData: ItemsList = [:]

    let searchData = [
      "do": "search",
      //"titleonly": "3",
      "subaction": "search",
      "search_start": "\(page)",
      "full_search": "0",
      "result_from": "\((page-1) * perPage + 1)",
      "story": query.windowsCyrillicPercentEscapes()
    ]

//    if page > 1 {
//      searchData["result_from"] = "\(page * perPage + 1)"
//    }

    let path = "/index.php?do=search"

    if let document = try searchDocument(KinoGoAPI.SiteUrl + path, parameters: searchData) {
      let items = try document.select("div[class=shortstory]")

      for item: Element in items.array() {
        let title = try item.select("div[class=shortstorytitle]")
        let shortimg = try item.select("div[class=shortimg]")

        let name = try title.text()

        let href = try shortimg.select("img").attr("title")

        let description = try shortimg.select("div div").text()
        let thumb = try shortimg.select("img").first()!.attr("src")
        var type = "movie"

        if name.contains("Сезон") || name.contains("сезон") {
          type = "serie"
        }

        data.append(["id": href, "name": name, "description": description, "thumb": KinoGoAPI.SiteUrl + thumb, "type": type])
      }

      if items.size() > 0 {
        paginationData = try extractPaginationData(document, page: page)
      }
    }

    return ["movies": data, "pagination": paginationData]
  }

  func extractPaginationData(_ document: Document, page: Int) throws -> [String: Any] {
    var pages = 1

    let paginationRoot = try document.select("div[class=bot-navigation]")

    if !paginationRoot.array().isEmpty {
      let paginationNode = paginationRoot.get(0)

      let links = try paginationNode.select("a").array()

      if let number = Int(try links[links.count-2].text()) {
        pages = number
      }
    }

    return [
      "page": page,
      "pages": pages,
      "has_previous": page > 1,
      "has_next": page < pages
    ]
  }

  public func getSeasons(_ path: String, _ name: String?=nil, _ thumb: String?=nil) throws -> [Season] {
    var list: [Season] = []

    if let document = try getDocument(path) {
      let items = try document.select("script")

      for item: Element in items.array() {
        let text = try item.html()

        if !text.isEmpty {
          let index1 = text.find("var seasons = ")

          if let startIndex = index1 {
            let text2 = String(text[startIndex..<text.endIndex])

            let text3 = text2

            let index2 = text3.find("}];")

            if let endIndex = index2 {
              let text4 = text3[text.index(text3.startIndex, offsetBy: 14) ..< endIndex]

              let text5 = text4.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines)

              let text6 = String(text5[text5.startIndex ..< text5.index(text5.endIndex, offsetBy: 0)] + "}]")

              let playlistContent = text6.replacingOccurrences(of: "'", with: "\"")
                .replacingOccurrences(of: ":", with: ": ")
                .replacingOccurrences(of: ",", with: ", ")

              if let localizedData = playlistContent.data(using: .utf8) {
                if let seasons = try? localizedData.decoded() as [Season] {
                  for season in seasons {
                    list.append(season)
                  }
                }
                else if let result = try? localizedData.decoded() as [Episode] {
                  let comment = (name != nil) ? name! : ""

                  let season = Season(comment: comment, playlist: result)

                  list.append(season)
                }
              }
              break
            }
          }
        }
      }
    }

    return list
  }

  func getHeaders(_ referer: String="") -> [String: String] {
    var headers = [
      "User-Agent": UserAgent,
      "referer": "https://kinogo.by/russkie-serialy/tnt/"
    ];

    if !referer.isEmpty {
      headers["Referer"] = referer
    }

    return headers
  }

}
