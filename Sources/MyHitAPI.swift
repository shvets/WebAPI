import Foundation
import SwiftyJSON
import SwiftSoup

open class MyHitAPI: HttpService {
  public let URL = "https://my-hit.org"
  let USER_AGENT = "My Hit User Agent"

  public func available() throws -> Elements {
    let document = try fetchDocument(URL)

    return try document!.select("div[class='container'] div[class='row']")
  }

  func getPagePath(path: String, page: Int=1) -> String {
    var newPath: String

    if page == 1 {
      newPath = path
    }
    else {
      var params = [String: String]()
      params["p"] = String(page)

      newPath = buildUrl(path: path, params: params as [String : AnyObject])
    }

    return newPath
  }
 
  public func getAllMovies(page: Int=1) throws -> Items {
    return try getMovies(path: "/film/", page: page)
  }

  public func getAllSeries(page: Int=1) throws -> Items {
    return try getSeries(path: "/serial/", page: page)
  }

  public func getPopularMovies(page: Int=1) throws -> Items {
    return try getMovies(path: "/film/?s=3", page: page)
  }

  public func getPopularSeries(page: Int=1) throws -> Items {
    return try getSeries(path: "/serial/?s=3", page: page)
  }

  public func getMovies(path: String, type: String="movie", selector: String="film-list", page: Int=1) throws -> Items {
    var data: [Any] = []
    var paginationData: Items = [:]

    let pagePath = getPagePath(path: path, page: page)

    let document = try fetchDocument(URL + pagePath)

    let items = try document!.select("div[class='" + selector + "'] div[class='row']")

    for item: Element in items.array() {
      let link = try item.select("a").get(0)
      let href = try link.attr("href")

      var name = try link.attr("title")

      let index1 = name.startIndex
      let index2 = name.index(name.endIndex, offsetBy: -18)
      name = name[index1 ..< index2]

      let url = try link.select("div img").get(0).attr("src")

      let thumb = self.URL + url

      data.append(["type": type, "id": href, "thumb": thumb, "name": name])
    }

    let starItems = try document!.select("div[class='" + selector + "'] div[class='row star']")

    print(starItems.array().count)

    for item: Element in starItems.array() {
      let link = try item.select("a").get(0)
      let href = try link.attr("href")

      let name = try link.attr("title")

      let url = try link.select("img").get(0).attr("src")

      let thumb = self.URL + url

      data.append(["type": "star", "id": href, "thumb": thumb, "name": name])
    }

    if items.size() > 0 {
      paginationData = try extractPaginationData(pagePath, selector: selector, page: page)
    }

    return ["movies": data, "pagination": paginationData]
  }

  public func getSeries(path: String, page: Int=1) throws -> Items {
    return try getMovies(path: path, type: "serie", selector: "serial-list", page: page)
  }

  public func getSoundtracks(page: Int=1) throws -> Items {
    var data: [Any] = []
    var paginationData: Items = [:]

    let path = "/soundtrack/"
    let selector = "soundtrack-list"

    let pagePath = getPagePath(path: path, page: page)

    let document = try fetchDocument(URL + pagePath)

    let items = try document!.select("div[class='" + selector + "'] div[class='row'] div")

    for item: Element in items.array() {
      let link1 = try item.select("div b a").get(0)
      let link2 = try item.select("a").get(0)

      let href = try link1.attr("href")
      let name = try link1.text()

      let imgBlock = try link2.select("img")

      if imgBlock.size() > 0 {
        let thumb = URL + (try imgBlock.attr("src"))

        data.append(["type": "soundtrack", "id": href, "name": name, "thumb": thumb])
      }
    }

    if items.size() > 0 {
      paginationData = try extractPaginationData(pagePath, selector: selector, page: page)
    }

    return ["movies": data, "pagination": paginationData]
  }

  public func getAlbums(_ path: String) throws -> Items {
    var data: [[String: Any]] = []

    let pagePath = getPagePath(path: path)

    let document = try fetchDocument(URL + pagePath)

    var allTracks: [[[String: Any]]] = []

    let tracksBlock = try document?.select("div table[id='soundtrack_modify_table']")

    for (index, trackBlock) in tracksBlock!.array().enumerated() {
      let trackItems = try trackBlock.select("tbody tr")

      allTracks.append([])

      for trackItem in trackItems.array() {
        let children = trackItem.children()

        if children.size() == 5 {
          let name = try children.get(1).text()
          let duration = try children.get(2).text()
          let bitrate = try children.get(3).text()
          let url = try children.get(4).select("a").attr("href")

          let record = ["url": URL + url, "name": name, "duration": duration, "bitrate": bitrate]

          allTracks[index].append(record)
        }
      }
    }

    let items = try document!.select("div[class='container'] div[class='row'] div[class='row']")

    var index1: Int = -1

    for (_, item) in items.array().enumerated() {
      let img = try item.select("div a img")

      if img.size() > 0 {
        index1 = index1 + 1
        let src = try img.get(0).attr("src")
        let thumb = URL + src
        let name = try item.select("div a").attr("title")

        var composer = ""

        let liItems = try item.select("div ul li")

        for li: Element in liItems.array() {
          let text = try li.html()

          if text.find("Композитор:") != nil {
            let index = text.index(text.startIndex, offsetBy: "Композитор:".characters.count)

            composer = text[index ..< text.endIndex]
          }
        }

        data.append([ "thumb": thumb, "name": name, "composer": composer, "tracks": allTracks[index1]])
      }
    }

    var albums: [Any] = []

    for (_, album) in data.enumerated() {
      let name = album["name"] as! String
      let thumb = album["thumb"] as! String
      let artist = album["composer"] as! String
      let tracks = album["tracks"] as! [[String: Any]]

      var tracksData: [[String: Any]] = []

      for track in tracks {
        let url = track["url"]!
        let name = track["name"]!
        let format = "mp3"
        let bitrate = track["bitrate"]!
        let duration = track["duration"]!

        tracksData.append(["type": "track", "id": url, "name": name, "artist": artist, "thumb": thumb,
                           "format": format, "bitrate": bitrate, "duration": duration])
      }

      albums.append(["type": "tracks", "name": name, "thumb": thumb, "artist": artist, "tracks": tracksData])
    }

    return ["movies": albums]
  }

  public func getSelections(page: Int=1) throws -> Items {
    var data: [Any] = []
    var paginationData: Items = [:]

    let path = "/selection/"
    let selector = "selection-list"

    let pagePath = getPagePath(path: path, page: page)

    let document = try fetchDocument(URL + pagePath)

    let items = try document!.select("div[class='" + selector + "'] div[class='row'] div")

    for item: Element in items.array() {
      let link1 = try item.select("div b a").get(0)
      let link2 = try item.select("a").get(0)

      let href = try link1.attr("href")
      let name = try link1.text()

      let thumb = try link2.select("img").attr("src")

      if thumb != "" {
        if name != "Актёры и актрисы" && name != "Актеры и актрисы" {
          data.append(["type": "selection", "id": href, "thumb": self.URL + thumb, "name": name])
        }
      }
    }

    if items.size() > 0 {
      paginationData = try extractPaginationData(pagePath, selector: selector, page: page)
    }

    return ["movies": data, "pagination": paginationData]
  }

  func getSelectionId(_ path: String) -> String {
    let index = path.index(path.startIndex, offsetBy: 2)

    return path[index ..< path.endIndex]
  }

  public func getSelection(path: String, page: Int=1) throws -> Items {
    var data: [Any] = []
    var paginationData: Items = [:]

    let selector = "selection-view"

    let id = self.getSelectionId(path)

    let pagePath = getPagePath(path: "/selection/" + id + "/", page: page)

    let document = try fetchDocument(URL + pagePath)

    let items = try document!.select("div[class='" + selector + "'] div[class='row']")

    for item: Element in items.array() {
      let link = try item.select("div a").get(0)

      let href = try link.attr("href")
      var name = try link.attr("title")

      let index1 = name.startIndex
      let index2 = name.index(name.endIndex, offsetBy: -18-1)

      name = name[index1 ... index2]

      let url = try link.select("div img").get(0).attr("src")

      let thumb = URL + url

      let type = (href.find("/serial") != nil) ? "serie" : "movie"

      data.append(["type": type, "id": href, "thumb": thumb, "name": name])
    }

    if items.size() > 0 {
      paginationData = try extractPaginationData(pagePath, selector: selector, page: page)
    }

    return ["movies": data, "pagination": paginationData]
  }

  public func getFilters(mode: String="film") throws -> [Any] {
    var data: [Any] = []

    let document = try fetchDocument(URL + "/" + mode + "/")

    var currentGroupName: String = ""

    let selector = "sidebar-nav"

    let items = try document!.select("div[class='" + selector + "'] ul li")

    for item: Element in items.array() {
      let clazz = try item.attr("class")

      if clazz == "nav-header" {
        let name = try item.text().replacingOccurrences(of: ":", with: "")

        currentGroupName = name

        data.append(["name": name, "items": []])
      }
      else if clazz == "text-nowrap" {
        let link = try item.select("a").get(0)

        let href = try link.attr("href")
        let name = try link.text()

        appendItem(collection: &data, name: currentGroupName, item: ["id": href, "name": name])
      }
      else if clazz == "dropdown" {
        resetItems(collection: &data, name: currentGroupName)

        let liItems = try item.select("ul li")

        var currentGroup: [Any] = []

        for liItem in liItems.array() {
          let link = try liItem.select("a").get(0)
          let href = try link.attr("href")
          let name = try link.text()

          currentGroup.append(["id": href, "name": name])
        }

        replaceItems(collection: &data, name: currentGroupName, items: currentGroup)
      }
    }

    return data
  }

  func itemIndex(_ collection: [Any], name: String) -> Int? {
    return collection.index { item in
      let nm = (item as! [String: Any])["name"]!

      return nm as! String == name
    }
  }

  func appendItem(collection: inout [Any], name: String, item: [String: Any]) {
    let currentIndex = itemIndex(collection, name: name)

    if currentIndex != nil {
      let group = (collection[currentIndex!] as! [String: Any])

      var items = (group["items"] as! [Any])

      items.append(item)

      let name = (group["name"] as! String)

      collection[currentIndex!] = ["name": name, "items": items]
    }
  }

  func resetItems(collection: inout [Any], name: String) {
    let currentIndex = itemIndex(collection, name: name)

    if currentIndex != nil {
      let group = (collection[currentIndex!] as! [String: Any])

      let name = (group["name"] as! String)

      collection[currentIndex!] = ["name": name, "items": []]
    }
  }

  func replaceItems(collection: inout [Any], name: String, items: [Any]) {
    let currentIndex = itemIndex(collection, name: name)

    if currentIndex != nil {
      collection[currentIndex!] = ["name": name, "items": items]
    }
  }

  public func search(_ query: String, page: Int=1) throws -> Items {
    let path = "/search/"

    var params = [String: String]()
    params["q"] = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    params["p"] = String(page)

    let fullPath = buildUrl(path: path, params: params as [String : AnyObject])

    return try getMovies(path: fullPath, page: page)
  }

  public func getSeasons(_ path: String) -> Items {
    var data: [Any] = []

    var result = JSON(data: fetchContent(URL + path + "/playlist.txt")!)

    let playlist = result["playlist"]
    
    if playlist != JSON.null && playlist[0]["playlist"].arrayValue.isEmpty {
      var episodeData: [Any] = []
    
      for (_, episode) in playlist {
        let episodeId = episode["file"].stringValue
        let episodeName = episode["comment"].stringValue
        let episodeThumb = URL + episode["poster"].stringValue
        
        episodeData.append([ "type": "episode", "id": episodeId, "name": episodeName, "thumb": episodeThumb])
      }
      
      data.append([ "type": "season", "name": "Сезон 1", "episodes": episodeData])
    }
    else {
      for (_, season) in playlist {
        let name = season["comment"].stringValue
        let episodes = season["playlist"]
        let thumb = URL + season["poster"].stringValue
        
        var episodeData: [Any] = []
        
        for (_, episode) in episodes {
          let episodeId = episode["file"].stringValue
          let episodeName = episode["comment"].stringValue
          let episodeThumb = URL + episode["poster"].stringValue
          
          episodeData.append([ "type": "episode", "id": episodeId, "name": episodeName, "thumb": episodeThumb])
        }
        
        data.append(["type": "season", "name": name, "thumb": thumb, "episodes": episodeData])
      }
    }

    return ["movies": data]
  }

  public func getMediaData(pathOrUrl: String) throws -> [String: Any] {
    var data: [String: Any] = [:]

    var url: String = ""

    if pathOrUrl.find("http://") == pathOrUrl.startIndex {
      url = pathOrUrl
    }
    else {
      url = URL + pathOrUrl
    }

    let document = try fetchDocument(url)

    let infoRoot = try document?.select("div[class='row']")

    if infoRoot!.size() > 0 {
      let infoNode = try infoRoot!.select("ul[class='list-unstyled']")

      for item: Element in infoNode.array() {
        let line = try item.text()

        let index = line.find(":")

        if index != nil {
          let key = line[line.startIndex ... index!]
          let value = sanitize(line[line.index(after: index!) ..< line.endIndex])

          if key == "Продолжительность" {
            data["duration"] = Int(value.replacingOccurrences(of: "мин.", with: "").trim())! * 60 * 1000
          }
          else if key == "Режиссер" {
            data["directors"] = value.trim().replacingOccurrences(of: ".", with: "").components(separatedBy: ",")
          }
          else if key == "Жанр" {
            data["tags"] = value.trim().components(separatedBy: ",")
          }
          else {
            data[key] = value
          }
        }
      }

      let text = try infoNode.get(1).html()

      let index = text.index(text.startIndex, offsetBy: "В ролях:".characters.count)

      let artists = text[index ..< text.endIndex].components(separatedBy: ",")

      data["artists"] = artists

      let descriptionNode = try infoRoot?.get(0).select("div[itemprop='description']")

      if descriptionNode != nil {
        var description = ""

        if descriptionNode!.size() > 0 {
          description = try descriptionNode!.get(0).text()
        }

        data["description"] = description
      }
    }

    return data
  }

  public func getMetadata(_ url: String) throws -> [String: String] {
    var data: [[String: String]] = []

    let sourceUrl = getBaseUrl(url) + "/manifest.f4m"

    let document = try fetchDocument(sourceUrl)

    let mediaBlock = try document?.select("manifest media")

    for media in mediaBlock!.array() {
      let width = Int(try media.attr("width"))!
      let height = Int(try media.attr("height"))!
      let bitrate = Int(try media.attr("bitrate"))! * 1000
      let url = try media.attr("url")

      data.append([ "width": width.description, "height": height.description, "bitrate": bitrate.description, "url": url ])
    }

    let bandwidth = extractBandwidth(url)

    var location = -1

    for (index, item) in data.enumerated() {
      let url = item["url"]!
      
      if url.find(bandwidth) != nil {
        location = index
        break
      }
    }

    return location == -1 ? [:] : data[location]
  }

  public func extractBandwidth(_ url: String) -> String {
    var pattern = "chunklist_b"

    var index11 = url.find(pattern)

    if index11 == nil {
      pattern = "chunklist"
      index11 = url.find(pattern)
    }

    let index1 = url.index(index11!, offsetBy: pattern.characters.count)
    let index2 = url.find(".m3u8")

    return url[index1 ... index2!]
  }

  public func getUrls(path: String="", url: String="") throws -> [String] {
    var urls: [String] = []

    var sourceUrl: String = ""

    if path != "" {
      sourceUrl = try getSourceUrl(URL + path)
    }
    else {
      sourceUrl = url
    }

    if sourceUrl != "" {
      urls = try self.getPlayListUrls(sourceUrl)
    }

    return urls.reversed()
  }

  func getSourceUrl(_ url: String) throws -> String {
    var name = ""

    let content = fetchContent(url, headers: getHeaders())
    let document = try toDocument(content)

    let scripts = try document?.select("div[class='row'] div script")

    for script in scripts!.array() {
      let html = try script.html()
      
      if html != "" {
        let index1 = html.find( "file:")
        let index2 = html.find(".f4m")
        let index21 = html.find(".m3u8")
        
        if index1 != nil && index2 != nil {
          let index3 = html.index(index1!, offsetBy: 6)
          let text = html[index3 ..< index2!]
          
          if text != "" {
            name = text + ".m3u8"
          }
        }
        
        if index1 != nil && index21 != nil {
          let index3 = html.index(index1!, offsetBy: 6)
          let text = html[index3 ..< index21!]
          
          if text != "" {
            name = text + ".m3u8"
          }
        }
      }
    }

    return name
  }

  func getPlayListUrls(_ url: String) throws -> [String] {
    var urls: [String] = []

    let playList = try getPlayList(url)

    playList.enumerateLines {(line, _) in
      if line[line.startIndex] != "#" {
        urls.append(line)
      }
    }

    return urls
  }

  func getPlayList(_ url: String, baseUrl: String="") throws -> String {
    var localBaseUrl = baseUrl

    if localBaseUrl.isEmpty {
      localBaseUrl = getBaseUrl(url)
    }

    let data = httpRequest(url: url).content
    let content = try toString(data!)

    var newLines: [String] = []

    content!.enumerateLines {(line, _) in
      if line[line.startIndex] == "#" {
        newLines.append(line)
      }
      else {
        newLines.append(localBaseUrl + "/" + line)
      }
    }

    return newLines.joined(separator: "\n")
  }

  func getBaseUrl(_ url: String) -> String {
    var pathComponents = url.components(separatedBy: "/")

    return pathComponents[0...pathComponents.count-2].joined(separator: "/")
  }

  func extractPaginationData(_ path: String, selector: String, page: Int) throws -> Items {
    let document = try fetchDocument(URL + path)

    var pages = 1

    let paginationRoot = try document?.select("div[class='" + selector + "'] ~ div[class='row']")

    if paginationRoot != nil {
      let paginationBlock = paginationRoot!.get(0)

      let text = try paginationBlock.text()

      let index11 = text.find(":")
      let index21 = text.find("(")

      if index11 != nil && index21 != nil {
        let index1 = text.index(index11!, offsetBy: 1)

        let items = Int(text[index1 ..< index21!].trim())

        pages = items! / 24

        if items! % 24 > 0 {
          pages = pages + 1
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

  func sanitize(_ str: String) -> String {
    let result = str.replacingOccurrences(of: "&nbsp;", with: "")

    return result
  }

  func getEpisodeUrl(url: String, season: String="", episode: String="") -> String {
    var episodeUrl = url

    if season != "" {
      episodeUrl = "\(url)?season=\(season)&episode=\(episode)"
    }

    return episodeUrl
  }

  func getHeaders() -> [String: String] {
    return [
      "User-Agent": USER_AGENT
    ]
  }

}
