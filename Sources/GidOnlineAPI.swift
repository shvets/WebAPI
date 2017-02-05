import Foundation
import SwiftyJSON
import SwiftSoup

open class GidOnlineAPI: HttpService {
  public static let SITE_URL = "http://gidonline.club"
  let USER_AGENT = "Gid Online User Agent"

  public static let CYRILLIC_LETTERS = [
    "А", "Б", "В", "Г", "Д", "Е", "Ё", "Ж", "З", "И", "Й", "К", "Л", "М", "Н", "О", "П",
    "Р", "С", "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш", "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", "Я"
  ]

  let SESSION_URL1 = "http://pandastream.cc/sessions/create_new"
  let SESSION_URL2 = "http://pandastream.cc/sessions/new"
  let SESSION_URL3 = "http://pandastream.cc/sessions/new_session"

  func sessionUrl() -> String {
    return SESSION_URL3
  }

  public func getPagePath(_ path: String, page: Int=1) -> String {
    var newPath: String

    if page == 1 {
      newPath = path
    }
    else {
      var params = [String: String]()
      params["p"] = String(page)

      newPath = "\(path)/page/\(page)/"
    }

    return newPath
  }

  public func getAllMovies(page: Int=1) throws -> [String: Any] {
    let document = try fetchDocument(getPagePath(GidOnlineAPI.SITE_URL, page: page))

    return try getMovies(document!)
  }

  public func getGenres(_ document: Document, type: String="") throws -> [Any] {
    var data = [Any]()

    let links = try document.select("div[id='catline'] li a")

    for link: Element in links.array() {
      let path = try link.attr("href")
      let text = try link.text()

      let index1 = text.index(after: text.startIndex)
      let index2 = text.index(before: text.endIndex)

      let name = text[text.startIndex...text.startIndex] + text[index1...index2].lowercased()

      data.append(["id": path, "name": name ])
    }

    let familyGroup = [
      data[14],
      data[15],
      data[12],
      data[8],
      data[10],
      data[5],
      data[13]
    ]

    let crimeGroup = [
      data[4],
      data[9],
      data[2],
      data[0]
    ]

    let fictionGroup = [
      data[20],
      data[19],
      data[17],
      data[18]
    ]

    let educationGroup = [
      data[1],
      data[7],
      data[3],
      data[6],
      data[11],
      data[16]
    ]

    switch type {
      case "FAMILY":
        return familyGroup
      case "CRIME":
        return crimeGroup
      case "FICTION":
        return fictionGroup
      case "EDUCATION":
        return educationGroup
    default:
        return familyGroup + crimeGroup + fictionGroup + educationGroup
    }
  }

  public func getTopLinks(_ document: Document) throws -> [Any] {
    var data = [Any]()

    let links = try document.select("div[id='topls'] a[class='toplink']")

    for link: Element in links.array() {
      let path = try link.attr("href")
      let name = try link.text()
      let thumb = GidOnlineAPI.SITE_URL + (try link.select("img").attr("src"))

      data.append(["type": "movie", "id": path, "name": name, "thumb": thumb])
    }

    return data
  }

  public func getActors(_ document: Document, letter: String="") throws -> [Any] {
    var data = [Any]()

    let list = fixName(try getCategory( "actors-dropdown", document: document))

    let allList = sortByName(list)

    if !letter.isEmpty {
      data = []

      for item in allList {
        let currentItem = item as! [String: Any]
        let name = currentItem["name"] as! String

        if name.hasPrefix(letter) {
          data.append(item)
        }
      }
    }
    else {
      data = allList
    }

    return fixPath(data)
  }

  public func getDirectors(_ document: Document, letter: String="") throws -> [Any] {
    var data = [Any]()

    let list = fixName(try getCategory( "director-dropdown", document: document))

    let allList = sortByName(list)

    if !letter.isEmpty {
      data = []

      for item in allList {
        let currentItem = item as! [String: Any]
        let name = currentItem["name"] as! String

        if name.hasPrefix(letter) {
          data.append(item)
        }
      }
    }
    else {
      data = allList
    }

    return fixPath(data)
  }

  public func getCountries(_ document: Document) throws -> [Any] {
    return fixPath(try getCategory("country-dropdown", document: document))
  }

  public func getYears(_ document: Document) throws -> [Any] {
    return fixPath(try getCategory("year-dropdown", document: document))
  }

  public func getSeasons(_ path: String) throws -> [Any] {
    return try getCategory("season", document: getMovieDocument(GidOnlineAPI.SITE_URL + path)!)
  }

  public func getEpisodes(_ path: String) throws -> [Any] {
    return try getCategory("episode", document: getMovieDocument(GidOnlineAPI.SITE_URL + path)!)
  }

  func getCategory(_ id: String, document: Document) throws -> [Any] {
    var data = [Any]()

    let links = try document.select("select[id='" + id + "'] option")

    for link: Element in links.array() {
      let id = try link.attr("value")
      let name = try link.text()

      if id != "#" {
        data.append(["id": id, "name": name])
      }
    }

    return data
  }

  public func getMovieDocument(_ url: String, season: String="", episode: String="") throws -> Document? {
    let content = try getMovieContent(url, season: season, episode: episode)

    return try toDocument(content)
  }

  func getMovieContent(_ url: String, season: String="", episode: String="") throws -> Data? {
    let document = try fetchDocument(url)!
    let gatewayUrl = try getGatewayUrl(document)

    var movieUrl: String!

    if !season.isEmpty {
      movieUrl = "\(gatewayUrl)?season=\(season)&episode=\(episode)"
    }
    else {
      movieUrl = gatewayUrl
    }

    if movieUrl.contains("//www.youtube.com") {
      movieUrl = movieUrl.replacingOccurrences(of: "//", with: "http://")
    }

    return fetchContent(movieUrl, headers: getHeaders(gatewayUrl))
  }

  func getGatewayUrl(_ document: Document) throws -> String {
    var gatewayUrl: String!

    let frameBlock = try document.select("div[class=tray]").array()[0]

    var urls = try frameBlock.select("iframe[class=ifram]").attr("src")

    if !urls.isEmpty {
      gatewayUrl = urls
    }
    else {
//      let url = GidOnlineAPI.SITE_URL + "/trailer.php"
//
//      let block1 = try document.select("head meta[id=meta]")
//
//      let block2 = try block1.select("@content")
//
//      let data = [
//        "id_post": ""
//        //try document.select("head meta[id=meta]").select("@content").array()
//      ]
//
//      let response = httpRequest(url: url, data: data, method: "post")
//
//      let content = response.content
//
//      let document2 = try toDocument(content)
//
//      urls = try document2!.select("iframe[class='ifram']").attr("src")
//
//      if urls.trim().characters.count > 0 {
//        gatewayUrl = urls
//      }
    }

    return gatewayUrl
  }

  public func getMovies(_ document: Document, path: String="") throws -> [String: Any] {
    var data = [Any]()
    var paginationData = [String: Any]()

    let items = try document.select("div[id=main] div[id=posts] a[class=mainlink]")

    for item: Element in items.array() {
      let href = try item.attr("href")
      let name = try item.select("span").text()
      let thumb = GidOnlineAPI.SITE_URL + (try item.select("img").attr("src"))

      data.append(["id": href, "name": name, "thumb": thumb ])
    }

    if !items.array().isEmpty {
      paginationData = try extractPaginationData(document, path: path)
    }

    return ["movies": data, "pagination": paginationData]
  }

  func extractPaginationData(_ document: Document, path: String) throws -> [String: Any] {
    var page = 1
    var pages = 1

    let paginationRoot = try document.select("div[id=page_navi] div[class='wp-pagenavi']")

    if !paginationRoot.array().isEmpty {
      let paginationBlock = paginationRoot.get(0)

      page = try Int(paginationBlock.select("span[class=current]").text())!

      let lastBlock = try paginationBlock.select("a[class=last]")

      if !lastBlock.array().isEmpty {
        let pagesLink = try lastBlock.get(0).attr("href")

        pages = try findPages(path, link: pagesLink)
      }
      else {
        let pageBlock = try paginationBlock.select("a[class='page larger']")
        let pagesLen = pageBlock.array().count

        if pagesLen == 0 {
          pages = page
        }
        else {
          let pagesLink = try pageBlock.get(pagesLen - 1).attr("href")

          pages = try findPages(path, link: pagesLink)
        }
      }
    }

    return [
      "page": page,
      "pages": pages,
      "has_previous": page > 1,
      "has_next": page < pages
    ]
  }

  public func getUrls(_ url: String, season: String = "", episode: String="") throws -> [[String: String]] {
    var newUrl = url

    if url.find(GidOnlineAPI.SITE_URL) != nil && url.find("http://")! == nil {
      newUrl = GidOnlineAPI.SITE_URL + url
    }

    let content = try getMovieContent(newUrl, season: season, episode: episode)

    let data = getSessionData(toString(content!)!)

    let headers = [
      "X-Requested-With": "XMLHttpRequest",
      "X-Iframe-Param": "Redirect"
    ]

    let response2 = httpRequest(url: sessionUrl(), headers: headers, query: data, method: "post")

    let data2 = JSON(data: response2.content!)

    let manifests = data2["mans"]

    let manifestUrl = manifests["manifest_m3u8"].rawString()!

    return try getPlayListUrls(manifestUrl).reversed()
  }

  override func getPlayListUrls(_ url: String) throws -> [[String: String]] {
    var urls = [[String: String]]()

    var items = [[String]]()

    let response = httpRequest(url: url)

    let playList = toString(response.content!)!

    var index = 0

    playList.enumerateLines {(line, _) in
      if !line.hasPrefix("#EXTM3U") {
        if line.hasPrefix("#EXT-X-STREAM-INF") {
          let pattern = "#EXT-X-STREAM-INF:RESOLUTION=(\\d*)x(\\d*),BANDWIDTH=(\\d*)"

          do {
            let regex = try NSRegularExpression(pattern: pattern)

            let matches = regex.matches(in: line, options: [], range: NSRange(location: 0, length: line.characters.count))

            let width = self.getMatched(line, matches: matches, index: 1)
            let height = self.getMatched(line, matches: matches, index: 2)
            let bandwidth = self.getMatched(line, matches: matches, index: 3)

            items.append(["", width!, height!, bandwidth!])
          }
          catch {
            print("Error in regular expression.")
          }
        }
        else {
          items[index][0] = line

          index += 1
        }
      }
    }

    for item in items {
      urls.append(["url": item[0], "width": item[1], "height": item[2], "bandwidth": item[3]])
    }

    return urls
  }

  func getSessionData(_ content: String) -> [String: String] {
    var items = [String: String]()

    var dataSection = false

    content.enumerateLines { (line, _) in
      if line.find("var cparam =") != nil {
        let index1 = line.find("'")
        let index2 = line.find(";")
        let index11 = line.index(index1!, offsetBy: 1)
        let index21 = line.index(index2!, offsetBy: -2)

        items["dparam"] = line[index11 ... index21]
      }
      else if line.find("var session_params = {") != nil {
        dataSection = true
      }
      else if dataSection == true {
        if line.find("};") != nil {
          dataSection = false
        }
        else if !line.isEmpty {
          var data = line

          data = data.replacingOccurrences(of: "'", with: "")
          data = data.replacingOccurrences(of: ",", with: "")

          let components = data.components(separatedBy: ":")

          if components.count > 1 {
            let key = components[0].trim()
            let value = components[1].trim()

            items[key] = value
          }
        }
      }
    }

    return items
  }

  public func search(_ query: String, page: Int=1) throws -> [String: Any] {
    let path = getPagePath(GidOnlineAPI.SITE_URL, page: page) + "/"

    var params = [String: String]()
    params["s"] = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    let fullPath = self.buildUrl(path: path, params: params as [String : AnyObject])

    let response = httpRequest(url: fullPath)
    let content = response.content

    let document = try toDocument(content!)

    let movies = try getMovies(document!, path: fullPath)

    if !movies.isEmpty {
      return movies
    }
    else {
      let document2 = try fetchDocument(response.url!.path)

      let mediaData = try getMediaData(document2!)

      if mediaData["title"] != nil {
        return ["movies": [
          "id": fullPath,
          "name": mediaData["title"],
          "thumb": mediaData["thumb"]
        ]]
      }
      else {
        return ["movies": []]
      }
    }
  }

  func searchActors(_ document: Document, query: String) throws -> [Any] {
    return searchInList(try getActors(document), query: query)
  }

  func searchDirectors(_ document: Document, query: String) throws -> [Any] {
    return searchInList(try getDirectors(document), query: query)
  }

  func searchCountries(_ document: Document, query: String) throws -> [Any] {
    return searchInList(try getCountries(document), query: query)
  }

  func searchYears(_ document: Document, query: String) throws -> [Any] {
    return searchInList(try getYears(document), query: query)
  }

  func searchInList(_ list: [Any], query: String) -> [Any] {
    var newList = [Any]()

    for item in list {
      let name = (item as! [String: String])["name"]!.lowercased()

      if name.find(query.lowercased()) != nil {
        newList.append(item)
      }
    }

    return newList
  }

  public func getMediaData(_ document: Document) throws -> [String: Any] {
    var data = [String: Any]()

    let mediaNode = try document.select("div[id=face]")

    if !mediaNode.array().isEmpty {
      let block = mediaNode.get(0)

      let thumb = try block.select("div img[class=t-img]").attr("src")

      data["thumb"] = GidOnlineAPI.SITE_URL + thumb

      let items1 = try block.select("div div[class=t-row] div[class='r-1'] div[class='rl-2']")
      let items2 = try block.select("div div[class=t-row] div[class='r-2'] div[class='rl-2']")

      data["title"] = try items1.array()[0].text()
      data["countries"] = try items1.array()[1].text().components(separatedBy: ",")
      data["duration"] = try items1.array()[2].text()
      data["year"] = try items2.array()[0].text()
      data["tags"] = try items2.array()[1].text().components(separatedBy: ", ")
      data["genres"] = try items2.array()[2].text().components(separatedBy: ", ")

      let  descriptionBlock = try document.select("div[class=description]").array()[0]

      data["summary"] = try descriptionBlock.select("div[class=infotext]").array()[0].text()

      data["rating"] = try document.select("div[class=nvz] meta").attr("content")
    }

    return data
  }

  public func getSerialInfo(_ path: String, season: String="", episode: String="") throws -> [String: Any] {
    var result = [String: Any]()

    let content = try getMovieContent(path, season: season, episode: episode)

    //let data = getSessionData(toString(content!)!)

    let document = try toDocument(content)

    var seasons = [Any]()

    let items1 = try document!.select("select[id=season] option")

    for item in items1.array() {
      let value = try item.attr("value")

      seasons.append(try item.text())

      if try item.attr("selected") != nil {
        result["current_season"] = value
      }
    }

    result["seasons"] = seasons

    var episodes = [Any]()

    let items2 = try document!.select("select[id=episode] option")

    for item in items2.array() {
      let value = try item.attr("value")

      episodes.append(try item.text())

      if try item.attr("selected") != nil {
        result["current_episode"] = value
      }
    }

    result["episodes"] = episodes

    return result
  }

  func findPages(_ path: String, link: String) throws -> Int {
    let searchMode = (!path.isEmpty && path.find("?s=") != nil)

    var pattern: String?

    if !path.isEmpty {
      if searchMode {
        pattern = GidOnlineAPI.SITE_URL + "/page/"
      }
      else {
        pattern = GidOnlineAPI.SITE_URL + path + "page/"
      }
    }
    else {
      pattern = GidOnlineAPI.SITE_URL + "/page/"
    }

    pattern = pattern!.replacingOccurrences(of: "/", with: "\\/")
    pattern = pattern!.replacingOccurrences(of: ".", with: "\\.")

    let rePattern = "(\(pattern!))(\\d*)\\/"

    let regex = try NSRegularExpression(pattern: rePattern)

    let matches = regex.matches(in: link, options: [], range: NSRange(location: 0, length: link.characters.count))

    if let matched = getMatched(link, matches: matches, index: 2) {
      return Int(matched)!
    }
    else {
      return 1
    }
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

  public func isSerial(_ path: String) throws -> Bool {
    let content = try getMovieContent(path)

    let text = toString(content)

    let data = getSessionData(text!)

//    let anySeason = try hasSeasons(path)
//
//    return data != nil && data["content_type"] == "serial" || anySeason

    return data != nil && data["content_type"] == "serial"
  }

  func hasSeasons(_ url: String) throws -> Bool {
    //let path = urlparse.urlparse(url).path

    let path = NSURL(fileURLWithPath: url).deletingLastPathComponent!.path
//    let dirUrl = url.URLByDeletingLastPathComponent!
//    print(dirUrl.path!)

    return try !getSeasons(path).isEmpty
  }

  func fixName(_ items: [Any]) -> [Any] {
    var newItems = [Any]()

    for item in items {
      var currentItem = (item as! [String: Any])

      let name = currentItem["name"] as! String

      let names = name.components(separatedBy: " ")

      var newName = ""
      var suffix = ""
      var delta = 0

      if names[names.count-1] == "мл." {
        delta = 1
        suffix = names[names.count-1]

        newName = names[names.count-2]
      }
      else {
        newName = names[names.count-1]
      }

      if names.count > 1 {
        newName += ","

        for index in 0 ..< names.count-1-delta {
          newName += " " + names[index]
        }
      }

      if !suffix.isEmpty {
        newName = newName + " " + suffix
      }

      currentItem["name"] = newName

      newItems.append(currentItem)
    }

    return newItems
  }

  func fixPath(_ items: [Any]) -> [Any] {
    var newItems = [Any]()

    for item in items {
      var currentItem = (item as! [String: Any])

      let path = currentItem["id"] as! String

      let index1 = path.index(path.startIndex, offsetBy: GidOnlineAPI.SITE_URL.characters.count, limitedBy: path.endIndex)
      let index2 = path.index(before: path.endIndex)

      if index1 != nil {
        currentItem["id"] = path[index1! ... index2]
      }
      else {
        currentItem["id"] = path
      }

      newItems.append(currentItem)
    }

    return newItems
  }

  func getEpisodeUrl(url: String, season: String, episode: String) -> String {
    var episodeUrl = url

    if !season.isEmpty {
      episodeUrl = "\(url)?season=\(season)&episode=\(episode)"
    }

    return episodeUrl
  }

  func getHeaders(_ referer: String) -> [String: String] {
    return [
      "User-Agent": USER_AGENT,
      "Referer": referer
    ]
  }

  func sortByName(_ list: [Any]) -> [Any] {
    return list.sorted { element1, element2 in
      let name1 = (element1 as! [String: Any])["name"] as! String
      let name2 = (element2 as! [String: Any])["name"] as! String

      return name1 < name2
    }
  }

}
