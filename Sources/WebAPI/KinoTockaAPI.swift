import Foundation

import Foundation
import SwiftSoup
import Alamofire

open class KinoTochkaAPI: HttpService {
  public static let SiteUrl = "http://kinotochka.club"
  let UserAgent = "KinoTochka User Agent"

  public func getDocument(_ url: String) throws -> Document? {
    return try fetchDocument(url, headers: getHeaders())
  }

  public func searchDocument(_ url: String, parameters: [String: String]) throws -> Document? {
    return try fetchDocument(url, headers: getHeaders(), parameters: parameters, method: .post)
  }

  public func available() throws -> Bool {
    if let document = try getDocument(KinoTochkaAPI.SiteUrl) {
      return try document.select("div[class=big-wrapper]").size() > 0
    }
    else {
      return false
    }
  }

  func getPagePath(_ path: String, page: Int=1) -> String {
    if page == 1 {
      return path
    }
    else {
      return "\(path)page/\(page)/"
    }
  }

  public func getAllMovies(page: Int=1) throws -> [String: Any] {
    return try getMovies("/allfilms/", page: page)
  }

  public func getNewMovies(page: Int=1) throws -> [String: Any] {
    return try getMovies("/new/", page: page)
  }

  public func getAllSeries(page: Int=1) throws -> [String: Any] {
    let result = try getMovies("/serials/", page: page, serie: true)

    return ["pagination": result["pagination"] as Any, "movies": try sanitizeNames(result["movies"] as! [Any])]
  }

  private func sanitizeNames(_ movies: Any) throws -> [Any] {
    var newMovies = [Any]()

    for var movie in movies as! [[String: String]] {
      let pattern = "(\\d*\\s(С|с)езон)\\s"

      let regex = try NSRegularExpression(pattern: pattern)

      if let name = movie["name"] {
        let correctedName = regex.stringByReplacingMatches(in: name, options: [], range: NSMakeRange(0, name.count), withTemplate: "")

        movie["name"] = correctedName

        newMovies.append(movie)
      }
    }

    return newMovies
  }

  public func getRussianAnimations(page: Int=1) throws -> [String: Any] {
    return try getMovies("/cartoon/otechmult/", page: page)
  }

  public func getForeignAnimations(page: Int=1) throws -> [String: Any] {
    return try getMovies("/cartoon/zarubezmult/", page: page)
  }

  public func getAnime(page: Int=1) throws -> [String: Any] {
    return try getMovies("/anime/", page: page)
  }

  public func getTvShows(page: Int=1) throws -> [String: Any] {
    let result = try getMovies("/show/", page: page, serie: true)

    return ["pagination": result["pagination"] as Any, "movies": try sanitizeNames(result["movies"] as! [Any])]
  }

//  private func fixShowType(_ movies: Any) throws -> [Any] {
//    var newMovies = [Any]()
//
//    for var movie in movies as! [[String: String]] {
//      movie["type"] = "serie"
//
//      newMovies.append(movie)
//    }
//
//    return newMovies
//  }

  public func getMovies(_ path: String, page: Int=1, serie: Bool=false) throws -> [String: Any] {
    var data = [Any]()
    var paginationData: ItemsList = [:]

    let pagePath = getPagePath(path, page: page)

    if let document = try getDocument(KinoTochkaAPI.SiteUrl + pagePath) {
      let items = try document.select("div[id=dle-content] div[class=custom1-item]")

      for item: Element in items.array() {
        let href = try item.select("a[class=custom1-img]").attr("href")
        let name = try item.select("div[class=custom1-title").text()
        let thumb = try item.select("a[class=custom1-img] img").first()!.attr("src")

        var type = serie ? "serie" : "movie";

        if name.contains("Сезон") || name.contains("сезон") {
          type = "serie"
        }

        data.append(["id": href, "name": name, "thumb": thumb, "type": type])
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
          let index1 = text.find("file:\"")

          if let startIndex = index1 {
            let text2 = String(text[startIndex..<text.endIndex])

            let text3 = text2.replacingOccurrences(of: "[480,720]", with: "720")

            let index2 = text3.find("\", ")

            if let endIndex = index2 {
              urls = text3[text.index(text3.startIndex, offsetBy: 6) ..< endIndex].components(separatedBy: ",")

              break
            }
          }
        }
      }
    }

    return urls.reversed()
  }

  public func getSeasonPlaylistUrl(_ path: String) throws -> String {
    var url = ""

    if let document = try getDocument(path) {
      let items = try document.select("script")

      for item: Element in items.array() {
        let text = try item.html()

        if !text.isEmpty {
          let index1 = text.find("pl:")

          if let startIndex = index1 {
            let text2 = String(String(text[startIndex ..< text.endIndex]))

            let index2 = text2.find("\",st:")

            if let endIndex = index2 {
              url = String(text2[text2.index(text2.startIndex, offsetBy:4) ..< endIndex])

              break
            }
          }
        }
      }
    }

    return url
  }

  public func search(_ query: String, page: Int=1, perPage: Int=15) throws -> [String: Any] {
    var data = [Any]()
    var paginationData: ItemsList = [:]

    var searchData = [
      "do": "search",
      "subaction": "search",
      "search_start": "\(page)",
      "full_search": "0",
      "result_from": "1",
      "story": query
    ]

    if page > 1 {
      searchData["result_from"] = "\(page * perPage + 1)"
    }

    let path = "/index.php?do=search"

    if let document = try searchDocument(KinoTochkaAPI.SiteUrl + path, parameters: searchData) {
      let items = try document.select("a[class=sres-wrap clearfix]")

      for item: Element in items.array() {
        let href = try item.attr("href")
        let name = try item.select("div[class=sres-text] h2").text()
        let description = try item.select("div[class=sres-desc]").text()
        let thumb = try item.select("div[class=sres-img] img").first()!.attr("src")

        var type = "movie"

        if name.contains("Сезон") || name.contains("сезон") {
          type = "serie"
        }

        data.append(["id": href, "name": name, "description": description, "thumb": thumb, "type": type])
      }

      if items.size() > 0 {
        paginationData = try extractPaginationData(document, page: page)
      }
    }

    return ["movies": data, "pagination": paginationData]
  }

  func extractPaginationData(_ document: Document, page: Int) throws -> [String: Any] {
    var pages = 1

    let paginationRoot = try document.select("span[class=navigation]")

    if !paginationRoot.array().isEmpty {
      let paginationNode = paginationRoot.get(0)

      let links = try paginationNode.select("a").array()

      if let number = Int(try links[links.count-1].text()) {
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

  public func getSeasons(_ path: String, _ thumb: String?=nil) throws -> [Any] {
    var data = [Any]()

    if let document = try getDocument(path) {
      let items = try document.select("ul[class=seasons-list]")

      for item: Element in items.array() {
        let links = try item.select("li a");

        for link in links {
          let href = try link.attr("href")
          let name = try link.text()

          var item = ["id": href, "name": name, "type": "season"]

          if let thumb = thumb {
            item["thumb"] = thumb
          }

          data.append(item)
        }
      }

      if items.array().count > 0 {
        for item: Element in items.array() {
          let name = try item.select("li b").text()

          var item = ["id": path, "name": name, "type": "season"]

          if let thumb = thumb {
            item["thumb"] = thumb
          }

          data.append(item)
        }
      }
      else {
        var item = ["id": path, "name": "Сезон 1", "type": "season"]

        if let thumb = thumb {
          item["thumb"] = thumb
        }

        data.append(item)
      }
    }

    return data
  }

  public func getEpisodes(_ playlistUrl: String, path: String) throws -> [Episode] {
    var list: [Episode] = []

    if let data = fetchData(playlistUrl, headers: getHeaders(path)),
       let content = String(data: data, encoding: .windowsCP1251) {
      if !content.isEmpty {
        if let index = content.find("{\"playlist\":") {
          let playlistContent = content[index ..< content.endIndex]

          if let localizedData = playlistContent.data(using: .windowsCP1251) {
            if let result = try? localizedData.decoded() as PlayList {
              for item in result.playlist {
                list = buildEpisodes(item.playlist)
              }
            }
            else if let result = try? localizedData.decoded() as SingleSeasonPlayList {
              list = buildEpisodes(result.playlist)
            }
          }
        }
      }
    }

    return list
  }

  func buildEpisodes(_ playlist: [Episode]) -> [Episode] {
    var episodes: [Episode] = []

    for item in playlist {
      let filesStr = item.file.components(separatedBy: ",")

      var files: [String] = []

      for item in filesStr {
        if !item.isEmpty {
          files.append(item)
        }
      }

      episodes.append(Episode(comment: item.comment, file: item.file, files: files))
    }

    return episodes
  }

  public func buildEpisode(comment: String, files: [String]) -> Episode {
    return Episode(comment: comment, file: "file", files: files)
  }

  public func getCollections() throws -> [Any] {
    var data = [Any]()

    let path = "/podborki_filmov.html"

    if let document = try getDocument(KinoTochkaAPI.SiteUrl + path) {
      let items = try document.select("div[id=dle-content] div div div")

      for item: Element in items.array() {
        let link = try item.select("a").array()

        if link.count > 1 {
          let href = try link[0].attr("href")
          let name = try link[1].text()
          let thumb = try link[0].select("img").attr("src")

          if href != "/playlist/" {
            data.append(["id": href, "name": name, "thumb": thumb])
          }
        }
      }
    }

    return data
  }

  public func getCollection(_ path: String, page: Int=1) throws -> [String: Any] {
    var data = [Any]()
    var paginationData: ItemsList = [:]

    let pagePath = getPagePath(path, page: page)

    // print(KinoTochkaAPI.SiteUrl + pagePath);

    if let document = try getDocument(KinoTochkaAPI.SiteUrl + pagePath) {
      let items = try document.select("div[id=dle-content] div[class=custom1-item]")

      for item: Element in items.array() {
        let href = try item.select("a[class=custom1-img]").attr("href")
        let name = try item.select("div[class=custom1-title").text()
        let thumb = try item.select("a[class=custom1-img] img").first()!.attr("src")

        var type = "movie"

        if name.contains("Сезон") || name.contains("сезон") {
          type = "serie"
        }

        data.append(["id": href, "name": name, "thumb": thumb, "type": type])
      }

      if items.size() > 0 {
        paginationData = try extractPaginationData(document, page: page)
      }
    }

    return ["movies": data, "pagination": paginationData]
  }

  public func getUserCollections() throws -> [Any] {
    var data = [Any]()

    let path = "/playlist/"

    if let document = try getDocument(KinoTochkaAPI.SiteUrl + path) {
      let items = try document.select("div[id=dle-content] div div div[class=custom1-img]")

      for item: Element in items.array() {
        let link = try item.select("a").array()

        if link.count > 1 {
          let href = try link[0].attr("href")
          let name = try link[1].text()
          let thumb = try link[0].select("img").attr("src")

          data.append(["id": href, "name": name, "thumb": thumb])
        }
      }
    }

    return data
  }

  public func getUserCollection(_ path: String, page: Int=1) throws -> [String: Any] {
    var data = [Any]()
    var paginationData: ItemsList = [:]

    let pagePath = getPagePath(path, page: page)

    print(KinoTochkaAPI.SiteUrl + pagePath);

    if let document = try getDocument(KinoTochkaAPI.SiteUrl + pagePath) {
      let items = try document.select("div[id=dle-content] div div")

      for item: Element in items.array() {
        let link = try item.select("div[class=p-playlist-post custom1-item custom1-img] a").array()

        if link.count == 2 {
          let href = try link[0].attr("href")
          let name = try link[1].text()
          let thumb = try link[0].select("img").attr("src")

          var type = "movie"

          if name.contains("Сезон") || name.contains("сезон") {
            type = "serie"
          }

          data.append(["id": href, "name": name, "thumb": thumb, "type": type])
        }
      }

      if items.size() > 0 {
        paginationData = try extractPaginationData(document, page: page)
      }
    }

    return ["movies": data, "pagination": paginationData]
  }

  func getHeaders(_ referer: String="") -> [String: String] {
    var headers = [
      "User-Agent": UserAgent
    ];

    if !referer.isEmpty {
      headers["Referer"] = referer
    }

    return headers
  }

}
