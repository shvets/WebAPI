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

    print(movieUrl)

    if movieUrl.contains("//www.youtube.com") {
      movieUrl = movieUrl.replacingOccurrences(of: "//", with: "http://")
    }

    return try fetchDocument(movieUrl, headers: getHeaders(gatewayUrl))
  }

  func getGatewayUrl(_ document: Document) throws -> String {
    var gatewayUrl: String!

    let frameBlock = try document.select("div[class=tray]")

    var urls = try frameBlock.select("iframe[class=ifram]").attr("src")

    if urls.characters.count > 0 {
      gatewayUrl = urls
    }
    else {
      let url = GidOnlineAPI.URL + "/trailer.php"

      print(try document.select("head meta[id=meta]"))

      let data = [
        //"id_post": try document.select("head meta[id=meta]").select("@content").array()[0]
        "id_post": "aaa"
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
