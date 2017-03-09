import Foundation
import SwiftyJSON
import SwiftSoup

open class AudioKnigiAPI: HttpService {
  public static let SiteUrl = "https://audioknigi.club"

  func getPagePath(path: String, page: Int=1) -> String {
    return "\(path)page\(page)/"
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
    let path = path
    //URI.decode(path)

    var pagePath = getPagePath(path: path, page: page)

    if period != "" {
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

    //if !items.array().isEmpty {
    let paginationData = try extractPaginationData(document: document, path: path, page: page)
    //}

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
      //href = link.attr("href")[SiteUrl.length..-1] + "/"

      data.append(["type": "collection", "id": href, "name": name ])
    }

    if !items.array().isEmpty {
      //paginationData = try extractPaginationData(document, path: path)
    }

    return ["items": data, "pagination": paginationData]
  }

  func getGenres(page: Int=1) throws -> [String: Any] {
    var data = [Any]()
    let paginationData = [String: Any]()

    let path = "/sections/"

    let pagePath = getPagePath(path: path, page: page)
    let document = try fetchDocument(AudioKnigiAPI.SiteUrl + pagePath)

    let items = try document!.select("td[class=cell-name]")

    for item: Element in items.array() {
      let link = try item.select("a")
      let name = try link.select("h4 a")
      let href = try link.attr("href")
      //href = link.get('href')[len(self.SiteUrl)+1:]

      let thumb = try link.select("img").attr("src")

      data.append(["type": "genre", "id": href, "name": name, "thumb": thumb ])
    }

    if !items.array().isEmpty {
      //paginationData = try extractPaginationData(document, path: path)
    }

    return ["items": data, "pagination": paginationData]
  }

  func getGenre(path: String, page: Int=1) throws -> [String: Any] {
    return try getBooks(path: path, page: page)
  }

  func extractPaginationData(document: Document, path: String, page: Int) throws -> Items {
    var pages = 1

    let paginationRoot = try document.select("div[class='paging']")

    let paginationBlock = paginationRoot.get(0)

    let items = try paginationBlock.select("ul li")

    var lastLink = try items.get(items.size() - 2).select("a")

    if lastLink.size() == 1 {
      lastLink = try items.get(items.size() - 3).select("a")

      pages = try Int(lastLink.text())!
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
    let document = try fetchDocument(AudioKnigiAPI.SiteUrl + pagePath)

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

  func generateAuthorsList(fileName: String) {
    let data = [Any]()

//    let result = getAuthors()
//
//    data += result["items"]
//
//    let pages = result["pagination"]["pages"]

//    for page in range(2, pages) {
//      result = getAuthors(page: page)
//
//      data += result["items"]
//    }

//    with open(fileName, 'w') as file:
//    file.write(json.dumps(data, indent=4))
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

  func groupItemsByLetter(items: [Any]) {
//    var groups = OrderedDict()
//
//    for item in items {
//      let name = item["name"]
//      let path = item["path"]
//
//      let groupName = ""
//      //name[0:3].upper()
//
////      if groupName ! in groups.keys {
////        var group = []
////
////        groups[groupName] = group
////      }
//
//      groups[groupName].append(["path": path, "name": name])
//    }
//
//    return mergeSmallGroups(groups)
  }

  func mergeSmallGroups(groups: [Any]) {
//    // merge groups into bigger groups with size ~ 20 records
//
//    var classifier = []
//
//    let groupSize = 0
//
//    classifier.append([])
//
//    var index = 0
//
//    for groupName in groups {
//      groupWeight = len(groups[groupName])
//      groupSize += groupWeight
//
//      if groupSize > 20 || startsWithDifferentLetter(classifier[index], name: groupName) {
//        groupSize = 0
//        classifier.append([])
//        index = index + 1
//      }
//
//      classifier[index].append(groupName)
//    }
//
//    // flatten records from different group within same classification
//    // assign new name in format firstName-lastName, e.g. ABC-AZZ
//
//    var newGroups = OrderedDict()
//
//    for groupNames in classifier {
//      let key = groupNames[0] + "-" + groupNames[len(groupNames) - 1]
//      newGroups[key] = []
//
//      for groupName in groupNames {
//        for item in groups[groupName] {
//          newGroups[key].append(item)
//        }
//      }
//    }
//
//    return newGroups
  }

  func startsWithDifferentLetter(_ list: [Any], name: String) -> Bool {
//    var result = false
//
//    for n in list {
//      if name[0] != n[0] {
//        result = true
//        break
//      }
//    }
//
//    return result

    return true
  }
}
