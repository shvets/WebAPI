import Foundation
import SwiftyJSON
import SwiftSoup

open class GidOnlineAPI: HttpService {
  public static let URL = "http://gidonline.club"
  let USER_AGENT = "Gid Online User Agent"

  let SESSION_URL1 = "http://pandastream.cc/sessions/create_new"
  let SESSION_URL2 = "http://pandastream.cc/sessions/new"

  func sessionUrl() -> String {
    return SESSION_URL1
  }

  func getPagePath(path: String, page: Int=1) -> String {
    var newPath: String

    if page == 1 {
      newPath = path
    }
    else {
      var params = [String: String]()
      params["p"] = String(page)

      newPath = "\(path)page/\(page)/"
    }

    return newPath
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

    let family_group = [
      data[14],
      data[15],
      data[12],
      data[8],
      data[10],
      data[5],
      data[13]
    ]

    let crime_group = [
      data[4],
      data[9],
      data[2],
      data[0]
    ]

    let fiction_group = [
      data[20],
      data[19],
      data[17],
      data[18]
    ]

    let education_group = [
      data[1],
      data[7],
      data[3],
      data[6],
      data[11],
      data[16]
    ]

    switch type {
      case "Family":
        return family_group
      case "Crime":
        return crime_group
      case "Fiction":
        return fiction_group
      case "Education":
        return education_group
    default:
        return family_group + crime_group + fiction_group + education_group
    }
  }

  public func getTopLinks(_ document: Document) throws -> [Any] {
    var data: [Any] = []

    let links = try document.select("div[id='topls'] a[class='toplink']")

    for link: Element in links.array() {
      let path = try link.attr("href")
      let name = try link.text()
      let thumb = GidOnlineAPI.URL + (try link.select("img").attr("src"))

      data.append(["path": path, "name": name, "thumb": thumb])
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

  func getMovieDocument2(_ url: String, season: String="", episode: String="") throws -> (String, Document?) {
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

//    return try fetchDocument(movieUrl, headers: getHeaders(gatewayUrl))

    let data = fetchContent(url, headers: getHeaders(gatewayUrl))

    let html = toString(data, encoding: .utf8)!
    let document = try toDocument(data, encoding: .utf8)

    return (html, document)
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

  func getMovies(_ document: Document, path: String="") throws ->  [String: Any]{
    var data: [Any] = []
    var paginationData: [String: Any] = [:]

    let items = try document.select("div[id=main] div[id=posts] a[class=mainlink]")

    for item: Element in items.array() {
      let href = try item.attr("href")
      let name = try item.select("span").text()
      let thumb = GidOnlineAPI.URL + (try item.select("img").attr("src"))

      data.append(["type": "movie", "path": href, "name": name, "thumb": thumb ])
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

  func retrieveUrls(_ url: String, season: String = "", episode: String="") throws -> [String] {
    var newUrl = url

    if url.find(GidOnlineAPI.URL)! != nil && url.find("http://")! != nil {
      newUrl = GidOnlineAPI.URL + url
    }

    let (content, document) = try getMovieDocument2(url, season: season, episode: episode)

    let data = getSessionData(content)

    let contentData = getContentData(content)

    let headers = [
      "X-Requested-With": "XMLHttpRequest",
      "Encoding-Pool": contentData
    ]

    return getUrls(headers, data: data)
  }

  func getUrls(_ headers: [String: String], data: [String: String]) -> [String] {
    var urls: [String] = []

    let response = httpRequest(url: sessionUrl(), headers: headers, data: data, method: "post")

//    let data = JSON.parse(response.body)
//
//    let manifestUrl = data["manifest_m3u8"]
//
//    let response2 = http_request(url: manifest_url)
//
//    let lines = StringIO.new(response2.body).readlines

//    lines.each_with_index do |line, index|
//    if line.start_with?('#EXTM3U')
//    next
//    elsif line.strip.size > 0 and not line.start_with?('#EXT-X-STREAM-INF')
//    data = lines[index-1].match /#EXT-X-STREAM-INF:RESOLUTION=(\d+)x(\d+),BANDWIDTH=(\d+)/
//
//urls << {type: 'movie', url: line.strip, width: data[1].to_i, height: data[2].to_i, bandwidth: data[3].to_i}
//end
//end

    return []
  }

  func getSessionData(_ content: String) -> [String: String] {
    let url = NSURL(string: sessionUrl())

    let path = url?.path

    print(url)
    print(path)
//    print(content)

    let expr1 = "$.post('\(path)'"
    let expr2 = "}).success("

    let index1 = content.find(expr1)

    print(index1)

    if index1 != nil {
      let index2 = content[index1! ..< content.endIndex].find(expr2)

      print(index2)
//      var sessionData = content[index1+expr1.size+1..index1+index2].strip
//
//      if sessionData {
//        session_data = session_data.gsub('condition_detected ? 1 : ', '')
//
//        new_session_data = replace_keys(session_data,
//          ["partner", "d_id", "video_token", "content_type", "access_key", "cd"])
//
//        JSON.parse(new_session_data)
      //}
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
