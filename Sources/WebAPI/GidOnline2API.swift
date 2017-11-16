import Foundation
import SwiftSoup
import SwiftyJSON
import Alamofire

open class GidOnline2API: HttpService {
  public static let SiteUrl = "http://gidonline-kino.club"
  let UserAgent = "Gid Online User Agent"

  public static let CyrillicLetters = [
    "А", "Б", "В", "Г", "Д", "Е", "Ё", "Ж", "З", "И", "Й", "К", "Л", "М", "Н", "О", "П",
    "Р", "С", "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш", "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", "Я"
  ]

  let SessionUrl1 = "http://pandastream.cc/sessions/create_new"
  let SessionUrl2 = "http://pandastream.cc/sessions/new"
  let SessionUrl3 = "http://pandastream.cc/sessions/new_session"

  func sessionUrl() -> String {
    return SessionUrl3
  }

  public func available() throws -> Bool {
    let document = try fetchDocument(GidOnlineAPI.SiteUrl)

    return try document!.select("div[id=main] div[id=posts] a[class=mainlink]").size() > 0
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
    let document = try fetchDocument(getPagePath(GidOnlineAPI.SiteUrl, page: page))

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
      let thumb = GidOnlineAPI.SiteUrl + (try link.select("img").attr("src"))

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

  public func getSeasons(_ url: String, parentName: String?=nil, thumb: String?=nil) throws -> [Any] {
    var newSeasons = [Any]()

    let seasons = try getCategory("season", document: getMovieDocument(url)!)

    for item in seasons {
      var season = item as! [String: String]

      season["type"] = "season"
      season["parentId"] = url

      if let parentName = parentName {
        season["parentName"] = parentName
      }

      if let thumb = thumb {
        season["thumb"] = thumb
      }

      season["parentId"] = url

      newSeasons.append(season)
    }

    return newSeasons
  }

  public func getEpisodes(_ url: String, seasonNumber: String, thumb: String?=nil) throws -> [Any] {
    var newEpisodes = [Any]()

    let serialInfo = try getSerialInfo(url, season: seasonNumber, episode: "1")

    let episodes = serialInfo["episodes"] as! [String]

    for name in episodes {
      let index1 = name.index(name.startIndex, offsetBy: 6)
      let index2 = name.endIndex

      let episodeNumber = name[index1..<index2]

      var episode = [String: String]()

      episode["name"] = name
      episode["id"] = url
      episode["type"] = "episode"
      episode["seasonNumber"] = seasonNumber
      episode["episodeNumber"] = String(episodeNumber)

      if let thumb = thumb {
        episode["thumb"] = thumb
      }

      newEpisodes.append(episode)
    }

    return newEpisodes
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
    var data: Data?

    let document = try fetchDocument(url)!
    let gatewayUrl = try getGatewayUrl(document)

    if let gatewayUrl = gatewayUrl {
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

      if let response = httpRequest(movieUrl, headers: getHeaders(gatewayUrl)) {
        if response.response!.statusCode == 302 {
          let newGatewayUrl = response.response!.allHeaderFields["Location"] as! String

          let response2 = httpRequest(movieUrl, headers: getHeaders(newGatewayUrl))!

          data = response2.data
        }
        else {
          data = response.data
        }
      }
    }

    return data
  }

  func getMovieContent2(_ url: String, season: String="", episode: String="") throws -> Data? {
    var data: Data?

    let document = try fetchDocument(url)!
    let gatewayUrl = try getGatewayUrl2(document)

    if let gatewayUrl = gatewayUrl {
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

      if let response = httpRequest(movieUrl, headers: getHeaders(gatewayUrl)) {
        if response.response!.statusCode == 302 {
          let newGatewayUrl = response.response!.allHeaderFields["Location"] as! String

          let response2 = httpRequest(movieUrl, headers: getHeaders(newGatewayUrl))!

          data = response2.data
        }
        else {
          data = response.data

          let document2 = try toDocument(data)!

          let iframeBlock = try document2.select("iframe")

          let url2 = try iframeBlock.attr("src")

          //print(url2)

          if let response3 = httpRequest(url2, headers: getHeaders(gatewayUrl)) {
            data = response3.data!
          }
        }
      }
    }

    return data
  }

  func getJsonData(_ content: String) -> [String] {
    var items = [String]()

    var dataSection = false

    content.enumerateLines { (line, _) in
      if line.find("HD.Player({") != nil {
        dataSection = true
      }
      else if dataSection == true {
        if line.find("};") != nil {
          dataSection = false
        }
        else if !line.isEmpty {
          //print(line)
          if line.find("media: ") != nil {
            let index1 = line.find("media:")
            let index2 = line.find("]")

            let index11 = line.index(index1!, offsetBy: 8)
            let index21 = line.index(index2!, offsetBy: -1)
            var urls = line[index11 ... index21]

//            urls = urls.replacingOccurrences(of: "\n", with: "")
//            urls = urls.replacingOccurrences(of: "\\", with: "")
//            urls = urls.replacingOccurrences(of: ",", with: ", ")
//            urls = urls.replacingOccurrences(of: "url:", with: "'url':")
//            urls = urls.replacingOccurrences(of: "type:", with: "'type':")

            let json = JSON(urls)

            print("[ " + urls + " ]")
            print(json)

            for (key, _) in json {
              print(key)
              //print(value)
            }

            items.append("http://cdn14.hdgo.cc/video/181541/1/b8e1767c3a706273ca729550103e3dc5.mp4")
            items.append("http://cdn14.hdgo.cc/video/181541/2/b8e1767c3a706273ca729550103e3dc5.mp4")
            items.append("http://cdn14.hdgo.cc/video/181541/3/b8e1767c3a706273ca729550103e3dc5.mp4")
            items.append("http://cdn14.hdgo.cc/video/181541/4/b8e1767c3a706273ca729550103e3dc5.mp4")

          }
//
//          var data = line
//
//          data = data.replacingOccurrences(of: "'", with: "")
//          data = data.replacingOccurrences(of: ",", with: "")
//
//          let components = data.components(separatedBy: ":")
//
//          if components.count > 1 {
//            let key = components[0].trim()
//            let value = components[1].trim()
//
//            items[key] = value
//          }
        }
      }
    }

    return items
  }

  func getGatewayUrl(_ document: Document) throws -> String? {
    var gatewayUrl: String?

    let frameBlock = try document.select("div[class=tray]").array()[0]

    var urls = try frameBlock.select("iframe[class=ifram]").attr("src")

    if !urls.isEmpty {
      gatewayUrl = urls
    }
    else {
      let url = "\(GidOnlineAPI.SiteUrl)/trailer.php"

      let idPost = try document.select("head meta[id=meta]").attr("content")

      let parameters: Parameters = [
        "id_post": idPost
      ]

      let document2 = try fetchDocument(url, parameters: parameters, method: .post)

      urls = try document2!.select("iframe[class='ifram']").attr("src")

      if !urls.trim().isEmpty {
        gatewayUrl = urls
      }
    }

    return gatewayUrl
  }

  func getGatewayUrl2(_ document: Document) throws -> String? {
    var gatewayUrl: String?

    let frameBlock = try document.select("div[class=tray]").array()[0]

    let iframeBlock = try frameBlock.select("iframe")

    var urls: [String] = []

    for item in iframeBlock {
      urls.append(try item.attr("src"))
    }

    print(urls)

    if !urls.isEmpty {
      gatewayUrl = urls[1]
    }
    else {
      let url = "\(GidOnlineAPI.SiteUrl)/trailer.php"

      let idPost = try document.select("head meta[id=meta]").attr("content")

      let parameters: Parameters = [
        "id_post": idPost
      ]

      let document2 = try fetchDocument(url, parameters: parameters, method: .post)

      let iframeBlock2 = try document2!.select("iframe")

      var urls: [String] = []

      for item in iframeBlock2 {
        urls.append(try item.attr("src"))
      }

      if !urls[0].trim().isEmpty {
        gatewayUrl = urls[0]
      }
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
      let thumb = GidOnlineAPI.SiteUrl + (try item.select("img").attr("src"))

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

  public func getUrls2(_ url: String, season: String = "", episode: String="") throws -> [[String: String]] {
    var newUrl = url

    if url.find(GidOnlineAPI.SiteUrl) != nil && url.find("http://") == nil {
      newUrl = GidOnlineAPI.SiteUrl + url
    }

    var baseUrls: [String] = []

    if let data = try getMovieContent2(newUrl, season: season, episode: episode) {
      baseUrls = getJsonData(String(data: data, encoding: .utf8)!)

      //print(items)
    }

    var urls: [[String: String]] = []

    for (index, url) in baseUrls.enumerated() {
      // 360, 480, 720, 1080
      urls.append(["url": url, "bandwidth": String(describing: index+1)])
    }

    var headers: [String: String] = [:]

    headers["Host"] = "cdn10.hdgo.cc"
    headers["Range"] = "bytes=0-"
    headers["Referer"] = "http://ru.d99q88vn.ru/video/XCwA9HElTOvpj7pXNYrSnWTv7ChXmYqO/2139/"
    headers["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36"

    print(urls[0]["url"]!)

    let response = httpRequest(urls[0]["url"]!, headers: headers)!

    if response.response!.statusCode == 302 {
      let newGatewayUrl = response.response!.allHeaderFields["Location"] as! String

      print("3")

      print(newGatewayUrl)

//      let response2 = httpRequest(movieUrl, headers: getHeaders(newGatewayUrl))!
//
//      data = response2.data
    }


//    let html = String(data: content!, encoding: .utf8)
//
//    let frameCommit = getRequestTokens(html!)
//
//    let parameters = getSessionData(html!)
//
//    let headers: HTTPHeaders = [
//      "X-Frame-Commit": frameCommit,
//      "X-Requested-With": "XMLHttpRequest"
//    ]
//
//    let response2 = httpRequest(sessionUrl(), headers: headers, parameters: parameters, method: .post)
//
//    let data2 = JSON(data: response2!.data!)
//
//    let manifests = data2["mans"]
//
//    print(manifests)
//
//    let manifestMp4Url = JSON(data: try manifests.rawData())["manifest_mp4"].rawString()!
//
//    print(manifestMp4Url)
//
//    return try getMp4Urls(manifestMp4Url).reversed()

    return urls
  }

  public func getUrls(_ url: String, season: String = "", episode: String="") throws -> [[String: String]] {
    var newUrl = url

    if url.find(GidOnlineAPI.SiteUrl) != nil && url.find("http://") == nil {
      newUrl = GidOnlineAPI.SiteUrl + url
    }

    let content = try getMovieContent(newUrl, season: season, episode: episode)

    let html = String(data: content!, encoding: .utf8)

    let frameCommit = getRequestTokens(html!)

    let parameters = getSessionData(html!)

    let headers: HTTPHeaders = [
      "X-Frame-Commit": frameCommit,
      "X-Requested-With": "XMLHttpRequest"
    ]

    let response2 = httpRequest(sessionUrl(), headers: headers, parameters: parameters, method: .post)

    let data2 = JSON(data: response2!.data!)

    let manifests = data2["mans"]

    print(manifests)

    let manifestMp4Url = JSON(data: try manifests.rawData())["manifest_mp4"].rawString()!

    print(manifestMp4Url)

    return try getMp4Urls(manifestMp4Url).reversed()

//    let manifestUrl = manifests["manifest_m3u8"].rawString()!.replacingOccurrences(of: "\\/", with: "/") + "&man_type=zip1&eskobar=pablo"
//
//    print(manifestUrl)
//
//    return try getPlayListUrls(manifestUrl).reversed()
  }

  func getRequestTokens(_ content: String) -> String {
    var frameCommit = ""

    var frameSection = false

    content.enumerateLines { (line, _) in
      if line.find("$.ajaxSetup({") != nil {
        frameSection = true
      }
      else if frameSection == true {
        if line.find("});") != nil {
          frameSection = false
        }
        else if !line.isEmpty {
          if line.find("'X-Frame-Commit'") != nil {
            let index1 = line.find("'X-Frame-Commit':")

            frameCommit = String(line[line.index(index1!, offsetBy: "'X-Frame-Commit':".count+2) ..< line.index(line.endIndex, offsetBy: -1)])
          }
        }
      }
    }

    return frameCommit
  }

  func getSessionData(_ content: String) -> [String: String] {
    var items = [String: String]()

    var mw_key: String?
    var random_key: String?

    var dataSection = false

    content.enumerateLines { (line, _) in
      if line.find("post_method.runner_go =") != nil {
        let index1 = line.find("'")
        let index2 = line.find(";")
        let index11 = line.index(index1!, offsetBy: 1)
        let index21 = line.index(index2!, offsetBy: -2)

        items["runner_go"] = String(line[index11 ... index21])
      }
//      else if line.find("var post_method = {") != nil {
//        dataSection = true
//      }
      else if line.find("var mw_key =") != nil {
        dataSection = true

        let index1 = line.find("'")
        let index2 = line.find(";")
        let index11 = line.index(index1!, offsetBy: 1)
        let index21 = line.index(index2!, offsetBy: -2)

        mw_key = String(line[index11 ... index21])
      }
      else if dataSection == true {
        if line.find("};") != nil {
          dataSection = false
        }
        else if !line.isEmpty {
          if line.find("var ") != nil {
            let index2 = line.find(" = {")
            let index11 = line.index(line.startIndex, offsetBy: 4)
            let index21 = line.index(index2!, offsetBy: -1)
            random_key = String(line[index11 ... index21])
          }

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

    if mw_key != nil {
      items["mw_key"] = mw_key
    }

//    if random_key != nil {
//      content.enumerateLines { (line, _) in
//        if line.find("\(random_key!)['") != nil {
//          let text1 = line.trim()
//
//          let index1 = text1.find("['")
//
//          let text2 = text1[index1! ..< text1.endIndex]
//
//          let index2 = text2.find("']")
//          let index3 = text2.find("= '")
//
//          let key = text2[text2.index(text2.startIndex, offsetBy: 2) ..< index2!]
//          let value = text2[text2.index(index3!, offsetBy: 3) ..< text2.index(text2.endIndex, offsetBy: -2)]
//
//          items[key] = value
//        }
//      }
//    }

    items["ad_attr"] = "0"
    items["mw_pid"] = "4"

    //print(items)

    return items
  }

  func getMp4Urls(_ url: String) throws -> [[String: String]] {
    var urls = [[String: String]]()

    let response = httpRequest(url)

    let list = JSON(data: response!.data!)

    for (bandwidth, url) in list {
      urls.append(["url": url.rawString()!.replacingOccurrences(of: "\\/", with: "/"), "bandwidth": bandwidth])
    }

    return urls
  }

  override func getPlayListUrls(_ url: String) throws -> [[String: String]] {
    var urls = [[String: String]]()

    var items = [[String]]()

    let response = httpRequest(url)

    let playList = String(data: response!.data!, encoding: .utf8)!

    var index = 0

    playList.enumerateLines {(line, _) in
      if !line.hasPrefix("#EXTM3U") {
        if line.hasPrefix("#EXT-X-STREAM-INF") {
          let pattern = "#EXT-X-STREAM-INF:RESOLUTION=(\\d*)x(\\d*),BANDWIDTH=(\\d*)"

          do {
            let regex = try NSRegularExpression(pattern: pattern)

            let matches = regex.matches(in: line, options: [], range: NSRange(location: 0, length: line.count))

            let width = self.getMatched(line, matches: matches, index: 1)
            let height = self.getMatched(line, matches: matches, index: 2)
            let bandwidth = self.getMatched(line, matches: matches, index: 3)

            items.append(["", width!, height!, bandwidth!])
          }
          catch {
            print("Error in regular expression.")
          }
        }
        else if !line.isEmpty {
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

  public func search(_ query: String, page: Int=1) throws -> [String: Any] {
    var result: [String: Any] = ["movies": []]

    let path = getPagePath(GidOnlineAPI.SiteUrl, page: page) + "/"

    var params = [String: String]()
    params["s"] = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    let fullPath = self.buildUrl(path: path, params: params as [String : AnyObject])

    if let response = httpRequest(fullPath),
       let data = response.data,
       let document = try toDocument(data) {
      let movies = try getMovies(document, path: fullPath)

      if !movies.isEmpty {
        result = movies
      }
      else {
        if let response = response.response,
           let url = response.url,
           let document2 = try fetchDocument(url.path) {

          let mediaData = try getMediaData(document2)

          if mediaData["title"] != nil {
            result = ["movies": [
              "id": fullPath,
              "name": mediaData["title"],
              "thumb": mediaData["thumb"]
            ]]
          }
        }
      }
    }

    return result
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

      data["thumb"] = GidOnlineAPI.SiteUrl + thumb

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

      if try !item.attr("selected").isEmpty {
        result["current_season"] = value
      }
    }

    result["seasons"] = seasons

    var episodes = [Any]()

    let items2 = try document!.select("select[id=episode] option")

    for item in items2.array() {
      let value = try item.attr("value")

      episodes.append(try item.text())

      if try !item.attr("selected").isEmpty {
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
        pattern = GidOnlineAPI.SiteUrl + "/page/"
      }
      else {
        pattern = GidOnlineAPI.SiteUrl + path + "page/"
      }
    }
    else {
      pattern = GidOnlineAPI.SiteUrl + "/page/"
    }

    pattern = pattern!.replacingOccurrences(of: "/", with: "\\/")
    pattern = pattern!.replacingOccurrences(of: ".", with: "\\.")

    let rePattern = "(\(pattern!))(\\d*)\\/"

    let regex = try NSRegularExpression(pattern: rePattern)

    let matches = regex.matches(in: link, options: [], range: NSRange(location: 0, length: link.count))

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
      let capturedGroupIndex = match!.range(at: index)

      let index1 = link.index(link.startIndex, offsetBy: capturedGroupIndex.location)
      let index2 = link.index(index1, offsetBy: capturedGroupIndex.length-1)

      matched = String(link[index1 ... index2])
    }

    return matched
  }

  public func isSerial(_ path: String) throws -> Bool {
    let content = try getMovieContent(path)

    let text = String(data: content!, encoding: .utf8)

    let data = getSessionData(text!)

//    let anySeason = try hasSeasons(path)
//
//    return data != nil && data["content_type"] == "serial" || anySeason

    return data["content_type"] == "serial"
  }

//  func hasSeasons(_ url: String) throws -> Bool {
//    //let path = urlparse.urlparse(url).path
//
//    let path = NSURL(fileURLWithPath: url).deletingLastPathComponent!.path
////    let dirUrl = url.URLByDeletingLastPathComponent!
////    print(dirUrl.path!)
//
//    return try !getSeasons(path).isEmpty
//  }

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

      let index1 = path.index(path.startIndex, offsetBy: GidOnlineAPI.SiteUrl.count, limitedBy: path.endIndex)
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
      "User-Agent": UserAgent,
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
