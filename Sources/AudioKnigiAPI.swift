import Foundation
import SwiftyJSON
import SwiftSoup

open class AudioKnigiAPI: HttpService {
  public static let SiteUrl = "https://audioknigi.club"

  func getPagePath(path: String, page: Int=1) -> String {
    if page == 1 {
      return path
    }
    else {
      return "\(path)page\(page)/"
    }
  }

  func getAuthorsLetters() throws -> [Any] {
    return try getLetters(path: "/authors/", filter: "author-prefix-filter")
  }

  func getPerformersLetters() throws -> [Any] {
    return try getLetters(path: "/performers/", filter: "performer-prefix-filter")
  }

  func getLetters(path: String, filter: String) throws -> [Any] {
    var data = [Any]()

    let document = try fetchDocument(AudioKnigiAPI.SiteUrl + path)

    let items = try document!.select("ul[id='" + filter + "'] li a")

    for item in items.array() {
      let name = try item.text()

      data.append(name)
    }

    return data
  }

  func getNewBooks(page: Int=1) throws -> [String: Any] {
    return try getBooks(path: "/index/", page: page)
  }

  func getBestBooks(period: String, page: Int=1) throws -> [String: Any] {
    return try getBooks(path: "/index/views/", period: period, page: page)
  }

  func getBooks(path: String, period: String="", page: Int=1) throws -> [String: Any] {
//    var path = path.removingPercentEncoding!
//    path = path.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    var pagePath = getPagePath(path: path, page: page)

    if !period.isEmpty {
      pagePath = "\(pagePath)?period=\(period)"
    }

    let document = try fetchDocument(AudioKnigiAPI.SiteUrl + pagePath)

    return try getBookItems(document!, path: path, page: page)
  }

  func getBookItems(_ document: Document, path: String, page: Int) throws -> [String: Any] {
    var data = [Any]()

    let items = try document.select("article")

    for item: Element in items.array() {
      let link = try item.select("header h3 a")
      let name = try link.text()
      let href = try link.attr("href")
      let thumb = try item.select("img").attr("src")
      let description = try item.select("div[class='topic-content text']").text()
          //.children.first.content.strip

      data.append(["type": "book", "id": href, "name": name, "thumb": thumb, "description": description ])
    }

    let paginationData = try extractPaginationData(document: document, path: path, page: page)

    return ["items": data, "pagination": paginationData]
  }

  func getAuthors(page: Int=1) throws -> [String: Any] {
    return try getCollection(path: "/authors/", page: page)
  }

  func getPerformers(page: Int=1) throws -> [String: Any] {
    return try getCollection(path: "/performers/", page: page)
  }

  func getCollection(path: String, page: Int=1) throws -> [String: Any] {
    var data = [Any]()
    var paginationData = [String: Any]()

    let pagePath = getPagePath(path: path, page: page)
    let document = try fetchDocument(AudioKnigiAPI.SiteUrl + pagePath)

    let items = try document!.select("td[class=cell-name]")

    for item: Element in items.array() {
      let link = try item.select("h4 a")
      let name = try link.text()
      let href = try link.attr("href")

      let index = href.index(href.startIndex, offsetBy: AudioKnigiAPI.SiteUrl.characters.count)

      let id = href[index ..< href.endIndex] + "/"

      data.append(["type": "collection", "id": id, "name": name ])
    }

    if !items.array().isEmpty {
      paginationData = try extractPaginationData(document: document!, path: path, page: page)
    }

    return ["items": data, "pagination": paginationData]
  }

  func getGenres(page: Int=1) throws -> [String: Any] {
    var data = [Any]()
    var paginationData = [String: Any]()

    let path = "/sections/"

    let pagePath = getPagePath(path: path, page: page)
    let document = try fetchDocument(AudioKnigiAPI.SiteUrl + pagePath)

    let items = try document!.select("td[class=cell-name]")

    for item: Element in items.array() {
      let link = try item.select("a")
      let name = try link.select("h4 a").text()
      let href = try link.attr("href")

      let index = href.index(href.startIndex, offsetBy: AudioKnigiAPI.SiteUrl.characters.count)

      let id = href[index ..< href.endIndex]

      let thumb = try link.select("img").attr("src")

      data.append(["type": "genre", "id": id, "name": name, "thumb": thumb])
    }

    if !items.array().isEmpty {
      paginationData = try extractPaginationData(document: document!, path: path, page: page)
    }

    return ["items": data, "pagination": paginationData]
  }

  func getGenre(path: String, page: Int=1) throws -> [String: Any] {
    return try getBooks(path: path, page: page)
  }

  func extractPaginationData(document: Document, path: String, page: Int) throws -> Items {
    var pages = 1

    let paginationRoot = try document.select("div[class='paging']")

    if paginationRoot.size() > 0 {
      let paginationBlock = paginationRoot.get(0)

      let items = try paginationBlock.select("ul li")

      var lastLink = try items.get(items.size() - 1).select("a")

      if lastLink.size() == 1 {
        lastLink = try items.get(items.size() - 2).select("a")

        if try lastLink.text() == "последняя" {
          let link = try lastLink.select("a").attr("href")

          let index = link.find("page")!
          let index1 = link.index(index, offsetBy: "page".characters.count)
          let index2 = link.index(link.endIndex, offsetBy: -1)

          pages = Int(link[index1..<index2])!
        }
        else {
          pages = try Int(lastLink.text())!
        }
      }
      else {
        let href = try items.attr("href")

        let pattern = path + "page"

        let index1 = href.find(pattern)
        var index2 = href.find("/?")

//        if index2 != nil {
//          index2 = href.endIndex-1
//        }

        //pages = href[index1+pattern.length..index2].to_i
      }
    }

    return [
      "page": page,
      "pages": pages,
      "has_previous": page > 1,
      "has_next": page < pages
    ]
  }

  func search(query: String, page: Int=1) throws -> [String: Any] {
    let path = "/search/books/"

    let pagePath = getPagePath(path: path, page: page)

    var params = [String: String]()
    params["q"] = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    let fullPath = buildUrl(path: pagePath, params: params as [String : AnyObject])

    let document = try fetchDocument(AudioKnigiAPI.SiteUrl + fullPath)

    return try getBookItems(document!, path: path, page: page)
  }

  func getAudioTracks(url: String) throws -> [Any] {
    let bookId = 0

    let document = try fetchDocument(url)

    let scripts = try document!.select("script[type='text/javascript']")

    for script in scripts {
//      let scriptBody =  try script.text()
//
//      let index = scriptBody.select("$(document).audioPlayer")
//
//      if index >= 0 {
//        // bookId = scriptBody[28:scriptBody.find(',')]
//        bookId = 0
//
//        break
//      }
    }

//    if bookId > 0 {
//      let newUrl = AudioKnigiAPI.URL + "/rest/bid/\(bookId)"
//
//      let document2 =  try fetchDocument(newUrl)
//
//      //tracks = self.to_json(self.httpRequest(newUrl).read())
//      let tracks = [String: String]()
//
//      for track in tracks {
//        track["name"] = track["title"] + ".mp3"
//        track["url"] = track["mp3"]
//
////        track.delete("title")
////        track.delete("mp3")
//      }
//
//      return tracks
//    }
//    else {
//      return []
//    }

    return []
  }

  func generateAuthorsList(_ fileName: String) throws {
    var data = [Any]()

    var result = try getAuthors()

    data += (result["items"] as! [Any])

    //print(data.count)

    let pagination = result["pagination"] as! [String: Any]

    let pages = pagination["pages"] as! Int

    print(pages)

    for page in (2...pages) {
      result = try getAuthors(page: page)

      data += (result["items"] as! [Any])

      //print(data.count)
    }

    let jsonData = try JSON(data)
    let prettified = JsonConverter.prettified(jsonData)

    Files.createFile(fileName, data: prettified.data(using: String.Encoding.utf8))
  }

  func generatePerformersList(fileName: String) {
    let data = [Any]()

//    let result = self.getPerformers()
//
//    data += result["items"]
//
//    let pages = result["pagination"]["pages"]
//
//    for page in range(2, pages) {
//      result = getPerformers(page: page)
//
//      data += result["items"]
//    }

//    with open(fileName, 'w') as file:
//    file.write(json.dumps(data, indent=4))
  }

  func groupItemsByLetter(_ items: [[String: String]]) -> [(key: String, value: [String])] {
    var groups = [String: [[String: String]]]()

    for item in items {
      let name = item["name"]!
      let path = item["path"]!

      let index = name.index(name.startIndex, offsetBy: 3)
      let groupName = name[name.startIndex..<index].uppercased()

      if !groups.keys.contains(groupName) {
        let group: [[String: String]] = []

        groups[groupName] = group
      }

      groups[groupName]!.append(["path": path, "name": name])
    }

    let sortedGroups = groups.sorted { $0.key < $1.key }

    return mergeSmallGroups(sortedGroups)
  }

  func mergeSmallGroups(_ groups: [(key: String, value: [[String : String]])]) -> [(key: String, value: [String])] {
    // merge groups into bigger groups with size ~ 20 records

    var classifier: [[String]] = []

    var groupSize = 0

    classifier.append([])

    var index = 0

    for (groupName, group) in groups {
      let groupWeight = group.count
      groupSize += groupWeight

      if groupSize > 20 || startsWithDifferentLetter(classifier[index], name: groupName) {
        groupSize = 0
        classifier.append([])
        index = index + 1
      }

      classifier[index].append(groupName)
    }

    // flatten records from different group within same classification
    // assign new name in format firstName-lastName, e.g. ABC-AZZ

    var newGroups = [(key: String, value: [String])]()

    for groupNames in classifier {
      let key = groupNames[0] + "-" + groupNames[groupNames.count - 1]

      var value: [String] = []

      for groupName in groupNames {
        value.append(groupName)
      }

      newGroups.append((key: key, value: value))
    }

    return newGroups
  }

  func startsWithDifferentLetter(_ list: [String], name: String) -> Bool {
    var result = false

    for n in list {
      if name[name.startIndex] != n[name.startIndex] {
        result = true
        break
      }
    }

    return result
  }
}
