import Foundation
import SwiftyJSON
import SwiftSoup

open class GidOnlineAPI: HttpService {
  public static let URL = "http://gidonline.club"
  let USER_AGENT = "Gid Online User Agent"

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
    let document = try fetchDocument(getPagePath(GidOnlineAPI.URL, page: page))

    return try getMovies(document!)
  }

  public func getGenres(_ document: Document, type: String="") throws -> [Any] {
    var data: [Any] = []

    let links = try document.select("div[id='catline'] li a")

    for link: Element in links.array() {
      let path = try link.attr("href")
      let text = try link.text()

      let index1 = text.index(after: text.startIndex)
      let index2 = text.index(before: text.endIndex)

      let name = text[text.startIndex...text.startIndex] + text[index1...index2].lowercased()

      data.append(["path": path, "name": name ])
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
    var data: [Any] = []

    let links = try document.select("div[id='topls'] a[class='toplink']")

    for link: Element in links.array() {
      let path = try link.attr("href")
      let name = try link.text()
      let thumb = GidOnlineAPI.URL + (try link.select("img").attr("src"))

      data.append(["type": "movie", "id": path, "name": name, "thumb": thumb])
    }

    return data
  }

  public func getActors(_ document: Document, letter: String="") throws -> [Any] {
    var data: [Any] = []

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
    var data: [Any] = []

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

  func getCountries(_ document: Document) throws -> [Any] {
    return fixPath(try getCategory("country-dropdown", document: document))
  }

  func getYears(_ document: Document) throws -> [Any] {
    return fixPath(try getCategory("year-dropdown", document: document))
  }

  func getSeasons(_ path: String) throws -> [Any] {
    return try getCategory("season", document: getMovieDocument(GidOnlineAPI.URL + path)!)
  }

  func getEpisodes(_ path: String) throws -> [Any] {
    return try getCategory("episode", document: getMovieDocument(GidOnlineAPI.URL + path)!)
  }

  func getCategory(_ id: String, document: Document) throws -> [Any] {
    var data: [Any] = []

    let links = try document.select("select[id='" + id + "'] option")

    for link: Element in links.array() {
      let path = try link.attr("value")
      let name = try link.text()

      data.append(["path": path, "name": name])
    }

    return data
  }

  func getMovieDocument(_ url: String, season: String="", episode: String="") throws -> Document? {
    let gatewayUrl = try getGatewayUrl(fetchDocument(url)!)

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

    return try fetchDocument(movieUrl, headers: getHeaders(gatewayUrl))
  }

  func getMovieDocument2(_ url: String, season: String="", episode: String="") throws -> String {
    let gatewayUrl = try getGatewayUrl(fetchDocument(url)!)

    //print(gatewayUrl)

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

    let data = fetchContent(movieUrl, headers: getHeaders(gatewayUrl))

    let html = toString(data, encoding: .utf8)!
    //let document = try toDocument(data, encoding: .utf8)

    return html
  }

  func getGatewayUrl(_ document: Document) throws -> String {
    var gatewayUrl: String!

    let frameBlock = try document.select("div[class=tray]").array()[0]

    var urls = try frameBlock.select("iframe[class=ifram]").attr("src")

    if urls.characters.count > 0 {
      gatewayUrl = urls
    }
    else {
      let url = GidOnlineAPI.URL + "/trailer.php"

      let block1 = try document.select("head meta[id=meta]")

      let block2 = try block1.select("@content")

      let data = [
        "id_post": ""
        //try document.select("head meta[id=meta]").select("@content").array()
      ]

      let response = httpRequest(url: url, data: data, method: "post")

      let content = response.content

      let document2 = try toDocument(content)

      urls = try document2!.select("iframe[class='ifram']").attr("src")

      if urls.trim().characters.count > 0 {
        gatewayUrl = urls
      }
    }

    return gatewayUrl
  }

  public func getMovies(_ document: Document, path: String="") throws -> [String: Any] {
    var data: [Any] = []
    var paginationData: [String: Any] = [:]

    let items = try document.select("div[id=main] div[id=posts] a[class=mainlink]")

    for item: Element in items.array() {
      let href = try item.attr("href")
      let name = try item.select("span").text()
      let thumb = GidOnlineAPI.URL + (try item.select("img").attr("src"))

      data.append(["type": "movie", "id": href, "name": name, "thumb": thumb ])
    }

    if items.array().count > 0 {
      paginationData = try extractPaginationData(document, path: path)
    }

    return ["items": data, "pagination": paginationData]
  }

  func extractPaginationData(_ document: Document, path: String) throws -> [String: Any] {
    var page = 1
    var pages = 1

    let paginationRoot = try document.select("div[id=page_navi] div[class='wp-pagenavi']")

    if paginationRoot.array().count > 0 {
      let paginationBlock = paginationRoot.get(0)

      page = try Int(paginationBlock.select("span[class=current]").text())!

      let lastBlock = try paginationBlock.select("a[class=last]")

      if lastBlock.array().count > 0 {
        let pagesLink = try lastBlock.get(0).attr("href")

        pages = findPages(path, link: pagesLink)
      }
      else {
        let pageBlock = try paginationBlock.select("a[class='page larger']")
        let pagesLen = pageBlock.array().count

        if pagesLen == 0 {
          pages = page
        }
        else {
          let pagesLink = try pageBlock.get(pagesLen - 1).attr("href")

          pages = findPages(path, link: pagesLink)
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

    if url.find(GidOnlineAPI.URL) != nil && url.find("http://")! == nil {
      newUrl = GidOnlineAPI.URL + url
    }

    let content = try getMovieDocument2(newUrl, season: season, episode: episode)

    let data = getSessionData(content)

//    data["mw_pid"] = "4"
//    data["ad_attr"] = "0"
//    data["debug"] = "false"

    //let contentData = getContentData(content)

    let headers = [
      "X-Requested-With": "XMLHttpRequest",
      //"X-CSRF-Token": "",
      //jN1d8rl9v2FuqRYdRQ/zwHjlK0mH2PebcBS79q0UHkL3Cbvut+rMSh1ZMDqmbzP5CRoA6N5aBct5eMkZdZpUig==",
      "X-Iframe-Option": "Direct"
    ]

    return try getUrls0(headers, data: data)
  }

  public func getUrls0(_ headers: [String: String], data: [String: String]) throws -> [[String: String]] {
    let response = httpRequest(url: sessionUrl(), headers: headers, query: data, method: "post")

    let data = JSON(data: response.content!)

    let manifests = data["mans"]

    let manifestUrl = manifests["manifest_m3u8"].rawString()!

    return try getPlayListUrls2(manifestUrl).reversed()
  }

  func getPlayListUrls2(_ url: String) throws -> [[String: String]] {
    var urls: [[String: String]] = []

    var items: [[String]] = []

    let response2 = httpRequest(url: url)

    let playList = toString(response2.content!)!

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
            let bandwith = self.getMatched(line, matches: matches, index: 3)

            items.append(["", width!, height!, bandwith!])
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
      urls.append(["type": "movie", "url": item[0], "width": item[1], "height": item[2], "bandwdth": item[3]])
    }

    return urls
  }

  func getSessionData(_ content: String) -> [String: String] {
    let expr1 = "$.post(session_url, {"
    let expr2 = "}).success("

    let index1 = content.find(expr1)

    if index1 != nil {
      let rightPart = content[index1! ..< content.endIndex]

      let index2 = rightPart.find(expr2)

      if index2 != nil {
        let index3 = rightPart.index(rightPart.startIndex, offsetBy: expr1.characters.count)
        let index4 = rightPart.index(before: index2!)

        var sessionData = rightPart[index3 ... index4].trim()

        if sessionData != "" {
          sessionData = sessionData.replacingOccurrences(of: "'", with: "\"")
          sessionData = sessionData.replacingOccurrences(of: "ad_attr: condition_detected ? 1 : 0,", with: "")
          sessionData = sessionData.replacingOccurrences(of: "video_token", with: "\"video_token\"")
          sessionData = sessionData.replacingOccurrences(of: "content_type", with: "\"content_type\"")
          sessionData = sessionData.replacingOccurrences(of: "mw_key", with: "\"mw_key\"")
          sessionData = sessionData.replacingOccurrences(of: "mw_pid: null,", with: "")
          sessionData = sessionData.replacingOccurrences(of: "debug: false,", with: "")
          sessionData = sessionData.replacingOccurrences(of: "mw_domain_id", with: "\"mw_domain_id\"")
          sessionData = sessionData.replacingOccurrences(of: "uuid", with: "\"uuid\"")

          sessionData = "{\n" + sessionData + "\n}"

          var items: [String: String] = [:]

          for (key, value) in JSON(data: sessionData.data(using: .utf8)!) {
            items[key] = value.rawString()!
          }

          return items
        }
      }
    }

    return [:]
  }

  func getContentData(_ content: String) -> String {
//    let data = content.match(/setRequestHeader\|\|([^|]+)/m)
//
//    if data {
//      Base64.encode64(data[1]).strip
//    }
    return ""
  }

  func search(_ query: String, page: Int=1) throws -> [String: Any] {
    let path = getPagePath(GidOnlineAPI.URL, page: page) + "/"

    var params = [String: String]()
    params["q"] = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    let fullPath = self.buildUrl(path: path, params: params as [String : AnyObject])

    print(fullPath)

    let content = fetchContent(fullPath)

    var document = try toDocument(content!)

    print(fullPath)

    let movies = try getMovies(document!, path: fullPath)

    print(movies)

//    let items = (movies as! [String: Any])
//
//    if items.count > 0 {
//      return movies
//    }
//    else {
//      print(response.url)

//      document = fetchDocument(response.url)
//
//      let mediaData = getMediaData(document)
//
//      if "title" == true {
//      //in mediaData {
//        return ["items": [
//          "path": url,
//          "name": mediaData["title"],
//          "thumb": mediaData["thumb"]
//        ]]
//      }
//      else {
//        return ["items": []]
//      }
//    }

    return ["items": []]
  }

  func getMediaData(_ document: Document) throws -> [String: Any] {
    var data: [String: Any] = [:]

    let mediaNode = try document.select("div[id=face]")

    if mediaNode.array().count > 0 {
      let block = mediaNode.get(0)

      let thumb = try block.select("div img[class=t-img]").attr("src")

      print(thumb)

      data["thumb"] = GidOnlineAPI.URL + thumb

      let items1 = try block.select("div div[class=t-row] div[class='r-1'] div[class='rl-2']")
      let items2 = try block.select("div div[class=t-row] div[class='r-2'] div[class='rl-2']")

      print(items1.array())
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

  func getSerialInfo(_ document: Document) throws {
    var ret: [String: Any] = [:]

    ret["seasons"] = []
    ret["episodes"] = []

    let items = try document.select("select[id=season] option")

    print(items)

    for item: Element in items.array() {
      print(item)

//      let value = item.attr("value")
//
//      ret["seasons"][value] = item.text()
//
//      if item.attr("selected") {
//        ret["current_season"] = value
//      }
    }
  }

  func findPages(_ path: String, link: String) -> Int {
    let searchMode = (!path.isEmpty && path.find("?s=") != nil)

    var pattern: String?

    if !path.isEmpty {
      if searchMode {
        pattern = GidOnlineAPI.URL + "/page/"
      }
      else {
        pattern = GidOnlineAPI.URL + path + "page/"
      }
    }
    else {
      pattern = GidOnlineAPI.URL + "/page/"
    }

    pattern = pattern!.replacingOccurrences(of: "/", with: "\\/")
    pattern = pattern!.replacingOccurrences(of: ".", with: "\\.")

    let rePattern = "(\(pattern!))(\\d*)\\/"

    let regex = try! NSRegularExpression(pattern: rePattern)

    let matches = regex.matches(in: link, options: [], range: NSRange(location: 0, length: link.characters.count))

    if let matched = getMatched(link, matches: matches, index: 2) {
      return Int(matched)!
    }
    else {
      return 1
    }
  }

  func getMatched(_ link: String,  matches: [NSTextCheckingResult], index: Int) -> String? {
    var matched: String?

    let match = matches.first

    if index < match!.numberOfRanges {
      let capturedGroupIndex = match!.rangeAt(index)

      let index1 = link.index(link.startIndex, offsetBy: capturedGroupIndex.location)
      let index2 = link.index(index1, offsetBy: capturedGroupIndex.length-1)

      matched = link[index1 ... index2]
    }

    return matched
  }

  func isSerial(_ path: String) throws -> Bool {
    let document = try getMovieDocument(path)

    //let content = tostring(document.select("body")[0])
    let content = try document!.select("body").text()

    print(content)

    let data = getSessionData(content)

    let anySeason = try hasSeasons(path)

    return data != nil && data["content_type"] == "serial" || anySeason
  }

  func hasSeasons(_ url: String) throws -> Bool {
    //let path = urlparse.urlparse(url).path

    let path = NSURL(fileURLWithPath: url).deletingLastPathComponent!.path
//    let dirUrl = url.URLByDeletingLastPathComponent!
//    print(dirUrl.path!)

    return try getSeasons(path).count > 0
  }

  func fixName(_ items: [Any]) -> [Any] {
    var newItems: [Any] = []

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
    var newItems: [Any] = []

    for item in items {
      var currentItem = (item as! [String: Any])

      let path = currentItem["path"] as! String

      let index1 = path.index(path.startIndex, offsetBy: GidOnlineAPI.URL.characters.count, limitedBy: path.endIndex)
      let index2 = path.index(before: path.endIndex)

      if index1 != nil {
        currentItem["path"] = path[index1! ... index2]
      }
      else {
        currentItem["path"] = path
      }

      newItems.append(currentItem)
    }

    return newItems
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
