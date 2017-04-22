import Foundation
import SwiftSoup
import SwiftyJSON

open class KinoKongAPI: HttpService {
  public static let SiteUrl = "http://kinokong.cc"
  let UserAgent = "KinoKong User Agent"

  public func getDocument(_ url: String) throws -> Document? {
    return try fetchDocument(url, headers: getHeaders(), encoding: .windowsCP1251)
  }

  public func searchDocument(_ url: String, data: [String: String]) throws -> Document? {
    return try fetchDocument(url, headers: getHeaders(), data: data, method: "post", encoding: .windowsCP1251)
  }

  public func available() throws -> Bool {
    let document = try getDocument(KinoKongAPI.SiteUrl)

    return try document!.select("div[id=container]").size() > 0
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
    return try getMovies("/films/", page: page)
  }

  public func getNewMovies(page: Int=1) throws -> [String: Any] {
    return try getMovies("/films/novinki-kino", page: page)
  }

  public func getAllSeries(page: Int=1) throws -> [String: Any] {
    return try getMovies("/serial/", page: page)
  }

  public func getAnimations(page: Int=1) throws -> [String: Any] {
    return try getMovies("/multfilm/", page: page)
  }

  public func getAnime(page: Int=1) throws -> [String: Any] {
    return try getMovies("/anime/", page: page)
  }

  public func getTvShows(page: Int=1) throws -> [String: Any] {
    return try getMovies("/dokumentalnyy/", page: page)
  }

  public func getMovies(_ path: String, page: Int=1) throws -> [String: Any] {
    var data = [Any]()
    var paginationData: Items = [:]

    let pagePath = getPagePath(path, page: page)

    let document = try getDocument(KinoKongAPI.SiteUrl + pagePath)

    let items = try document!.select("div[class=owl-item]")

    for item: Element in items.array() {
      var href = try item.select("div[class=item] span[class=main-sliders-bg] a").attr("href")
      let name = try item.select("div[class=main-sliders-title] a").text()
      let thumb = try KinoKongAPI.SiteUrl +
        item.select("div[class=main-sliders-shadow] span[class=main-sliders-bg] ~ img").attr("src")

      let seasonNode = try item.select("div[class=main-sliders-shadow] div[class=main-sliders-season]").text()

      if href.find(KinoKongAPI.SiteUrl) != nil {
        let index = href.index(href.startIndex, offsetBy: KinoKongAPI.SiteUrl.characters.count)

        href = href[index ..< href.endIndex]
      }

      let type = seasonNode.isEmpty ? "movie" : "serie"

      data.append(["id": href, "name": name, "thumb": thumb, "type": type])
    }

    if items.size() > 0 {
      paginationData = try extractPaginationData(document, page: page)
    }

    return ["movies": data, "pagination": paginationData]
  }

  func getMoviesByRating(page: Int=1) throws -> [String: Any] {
    return try getMoviesByCriteriaPaginated("/?do=top&mode=rating", page: page)
  }

  func getMoviesByViews(page: Int=1) throws -> [String: Any] {
    return try getMoviesByCriteriaPaginated("/?do=top&mode=views", page: page)
  }

  func getMoviesByComments(page: Int=1) throws -> [String: Any] {
    return try getMoviesByCriteriaPaginated("/?do=top&mode=comments", page: page)
  }

  func getMoviesByCriteria(_ path: String) throws -> [Any] {
    var data = [Any]()

    let document = try getDocument(KinoKongAPI.SiteUrl + path)

    let items = try document!.select("div[id=dle-content] div div table tr")

    for item: Element in items.array() {
      let link = try item.select("td a")

      if link.array().count > 0 {
        var href = try link.attr("href")

        let index = href.index(href.startIndex, offsetBy: KinoKongAPI.SiteUrl.characters.count)

        href = href[index ..< href.endIndex]

        let name = try link.text().trim()

        let tds = try item.select("td").array()

        let rating = try tds[tds.count-1].text()

        data.append(["id": href, "name": name, "rating": rating, "type": "rating"])
      }
    }

    return data
  }

  public func getMoviesByCriteriaPaginated(_ path: String, page: Int=1, perPage: Int=25) throws -> [String: Any] {
    let data = try getMoviesByCriteria(path)

    var items: [Any] = []

    for (index, item) in data.enumerated() {
      if index >= (page-1)*perPage && index < page*perPage {
        items.append(item)
      }
    }

    let pagination = buildPaginationData(data, page: page, perPage: perPage)

    return ["movies": items, "pagination": pagination]
  }

  public func getTags() throws -> [Any] {
    var data = [Any]()

    let document = try getDocument(KinoKongAPI.SiteUrl + "/podborka.html")

    let items = try document!.select("div[class=podborki-item-block]")

    for item: Element in items.array() {
      let link = try item.select("a")
      let img = try item.select("a span img")
      let title = try item.select("a span[class=podborki-title]")
      let href = try link.attr("href")

      var thumb = try img.attr("src")

      if thumb.find(KinoKongAPI.SiteUrl) == nil {
        thumb = KinoKongAPI.SiteUrl + thumb
      }

      let name = try title.text()

      data.append(["id": href, "name": name, "thumb": thumb, "type": "movie"])
    }

    return data
  }

  func buildPaginationData(_ data: [Any], page: Int, perPage: Int) -> [String: Any] {
    let pages = data.count / perPage

    return [
      "page": page,
      "pages": pages,
      "has_next": page < pages,
      "has_previous": page > 1
    ]
  }

  func getSeries(_ path: String, page: Int=1) throws -> [String: Any] {
    return try getMovies(path, page: page)
  }

  public func getUrls(_ path: String) throws -> [String] {
    var urls: [String] = []

    let document = try getDocument(KinoKongAPI.SiteUrl + path)

    let items = try document!.select("script")

    for item: Element in items.array() {
      let text = try item.html()

      if !text.isEmpty {
        let index1 = text.find("\"file\":\"")
        let index2 = text.find("\"};")

        if let startIndex = index1, let endIndex = index2 {
          urls = text[text.index(startIndex, offsetBy: 8) ..< endIndex].components(separatedBy: ",")

          break
        }
      }
    }

    return urls.reversed()
  }

  public func getSeriePlaylistUrl(_ path: String) throws -> String {
    var url = ""

    let document = try getDocument(KinoKongAPI.SiteUrl + path)

    let items = try document!.select("script")

    for item: Element in items.array() {
      let text = try item.html()

      if !text.isEmpty {
        let index1 = text.find("pl:")

        if let startIndex = index1 {
          let text2 = text[startIndex ..< text.endIndex]

          let index2 = text2.find("\",")

          if let endIndex = index2 {
            url = text2[text2.index(text2.startIndex, offsetBy:4) ..< endIndex]

            break
          }
        }
      }
    }

    return url
  }

//  func getMovie(_ url: String) {
//
//  }

  public func  getUrlsMetadata(_ urls: [String]) {
//    urls_items = []
//
//    for index, url in enumerate(urls) {
//      let url_item = [
//        "url": url,
//        "config": {
//          "container": 'MP4',
//          "audio_codec": 'AAC',
//          "video_codec": 'H264',
//        }
//      }]
//
//      groups = url.split('.')
//      text = groups[len(groups)-2]
//
//      result = re.search('(\d+)p_(\d+)', text)
//
//      if result && len(result.groups()) == 2 {
//        url_item['config']['width'] = result.group(1)
//        url_item['config']['video_resolution'] = result.group(1)
//        url_item['config']['height'] = result.group(2)
//      }
//      else {
//        result = re.search('_(\d+)', text)
//
//        if result && len(result.groups()) == 1 {
//          url_item['config']['width'] = result.group(1)
//          url_item['config']['video_resolution'] = result.group(1)
//        }
//
//      }
//
//      urls_items.append(url_item)
//
//    }
//
//    return urls_items
  }

  public func getMetadata(_ url: String) -> [String: String] {
    var data = [String: String]()

    let groups = url.components(separatedBy: ".")

    let text = groups[groups.count-2]

    let pattern = "(\\d+)p_(\\d+)"

    do {
      let regex = try NSRegularExpression(pattern: pattern)

      let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.characters.count))

      if let width = getMatched(text, matches: matches, index: 1) {
        data["width"] = width
      }

      if let height = getMatched(text, matches: matches, index: 2) {
        data["height"] = height
      }
    }
    catch {
      print("Error in regular expression.")
    }

    return data
  }

  func getMatched(_ link: String, matches: [NSTextCheckingResult], index: Int) -> String? {
    var matched: String?

    let match = matches.first

    if match != nil && index < match!.numberOfRanges {
      let capturedGroupIndex = match!.rangeAt(index)

      let index1 = link.index(link.startIndex, offsetBy: capturedGroupIndex.location)
      let index2 = link.index(index1, offsetBy: capturedGroupIndex.length-1)

      matched = link[index1 ... index2]
    }

    return matched
  }

  public func getGroupedGenres() throws -> [String: [Any]] {
    var data = [String: [Any]]()

    let document = try getDocument(KinoKongAPI.SiteUrl)

    let items = try document!.select("div[id=header] div div div ul li")

    for item: Element in items.array() {
      let hrefLink = try item.select("a")
      let genresNode1 = try item.select("span em a")
      let genresNode2 = try item.select("span a")

      var href = try hrefLink.attr("href")

      if href == "#" {
        href = "top"
      }
      else {
        href = href[href.index(href.startIndex, offsetBy: 1) ..< href.index(href.endIndex, offsetBy: -1)]
      }

      var genresNode: Elements?

      if genresNode1.array().count > 0 {
        genresNode = genresNode1
      }
      else {
        genresNode = genresNode2
      }

      if genresNode!.array().count > 0 {
        data[href] = []

        for genre in genresNode! {
          let path = try genre.attr("href")
          let name = try genre.text()

          if !["/recenzii/", "/news/"].contains(path) {
            data[href]!.append(["id": path, "name": name])
          }
        }
      }
    }

    return data
  }

  public func search(_ query: String, page: Int=1, perPage: Int=15) throws -> [String: Any] {
    var searchData = [
      "do": "search",
      "subaction": "search",
      "search_start": "\(page)",
      "full_search": "1",
      "story": query.addingPercentEscapes(using: .windowsCP1251)!
      //urllib.quote(query.decode('utf8').encode('cp1251'))
    ]

    if page > 1 {
      searchData["result_from"] = "\(page * perPage + 1)"
    }

    let path = "/index.php?do=search"

    let document = try searchDocument(KinoKongAPI.SiteUrl + path, data: searchData)

    var data = [Any]()
    var paginationData: Items = [:]

    let items = try document!.select("div[class=owl-item]")

    for item: Element in items.array() {
      var href = try item.select("div[class=item] span[class=main-sliders-bg] a").attr("href")
      let name = try item.select("div[class=main-sliders-title] a").text()
      let thumb = try item.select("div[class=main-sliders-shadow] span[class=main-sliders-bg] ~ img").attr("src")

      let seasonNode = try item.select("div[class=main-sliders-shadow] span[class=main-sliders-season]").text()

      if href.find(KinoKongAPI.SiteUrl) != nil {
        let index = href.index(href.startIndex, offsetBy: KinoKongAPI.SiteUrl.characters.count)

        href = href[index ..< href.endIndex]
      }

      let type = seasonNode.isEmpty ? "movie" : "serie"
      data.append(["id": href, "name": name, "thumb": thumb, "type": type])
    }

    if items.size() > 0 {
      paginationData = try extractPaginationData(document, page: page)
    }

    return ["movies": data, "pagination": paginationData]
  }

  func extractPaginationData(_ document: Document?, page: Int) throws -> [String: Any] {
    var response = [String: Any]()

    var pages = 1

    let paginationRoot = try document!.select("div[class=basenavi] div[class=navigation]")

    if paginationRoot.array().count > 0 {
      let paginationNode = paginationRoot.get(0)

      let links = try paginationNode.select("a").array()

      pages = Int(try links[links.count-1].text())!
    }

    return [
      "page": page,
      "pages": pages,
      "has_previous": page > 1,
      "has_next": page < pages,
    ]
  }

  public func getSerieInfo(_ playlistUrl: String) throws -> [[String: Any]] {
    var serieInfo: [[String: Any]] = []

    let data = fetchContent(playlistUrl, headers: getHeaders())

    let content = toString(data, encoding: .windowsCP1251)!

    let index = content.find("{\"playlist\":")

    let playlistContent = content[index! ..< content.endIndex]

    var playlist = JSON(data: playlistContent.data(using: .windowsCP1251)!)["playlist"]

    if playlist != JSON.null && playlist.count > 0 && playlist[0]["playlist"] == JSON.null {
      serieInfo = [
        [
          "comment": "Сезон 1",
          "playlist": buildPlaylist(playlist)
        ]
      ]
    }
    else {
      for (_, item) in playlist {
        serieInfo.append([
          "comment": item["comment"].stringValue,
          "playlist": buildPlaylist(item["playlist"])
        ])
      }
    }

    return serieInfo
  }

  func buildPlaylist(_ playlist: JSON) -> [[String: Any]] {
    var newPlaylist: [[String: Any]] = []

    for (_, item) in playlist {
      let files = item["file"].stringValue.components(separatedBy: ",")

      var newFiles: [String] = []

      for file in files {
        if !file.isEmpty {
          newFiles.append(file)
        }
      }

      newPlaylist.append([
        "comment": item["comment"].stringValue,
        "file": newFiles
      ])
    }

    return newPlaylist
  }

  public func getSeasons(_ path: String, serieName: String, thumb: String) throws -> [Any] {
    var data = [Any]()

    print(path)

    let playlistUrl = try getSeriePlaylistUrl(path)

    print(playlistUrl)

    let serieInfo = try getSerieInfo(playlistUrl)

    for (index, item) in serieInfo.enumerated() {
      let seasonName = (item["comment"] as! String).replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")

      let episodes = getEpisodes(item["playlist"] as! Any, serieName: serieName, season: index+1, thumb: thumb)

      data.append(["type": "season", "id": path, "name": seasonName, "serieName": serieName,
                   "seasonNumber": index+1, "thumb": thumb, "episodes": episodes])
    }

    return data
  }

  func getEpisodes(_ playlist: Any, serieName: String, season: Int, thumb: String) -> [Any] {
    var data = [Any]()

    let episodes = JSON(playlist)

    for (index, episode) in episodes {
      let episodeName = episode["comment"].stringValue.replacingOccurrences(of: "<br>", with: "")
      let path = episode["file"].arrayValue[0].stringValue

      data.append(["type": "episode", "id": path, "season": season,
                   "name": episodeName, "serieName": serieName,
                   "thumb": thumb])
    }

    return data
  }


  func getEpisodeUrl(url: String, season: String, episode: String) -> String {
    var episodeUrl = url

    if !season.isEmpty {
      episodeUrl = "\(url)?season=\(season)&episode=\(episode)"
    }

    return episodeUrl
  }

  func getHeaders() -> [String: String] {
    return [
      "User-Agent": UserAgent
    ]
  }

}
