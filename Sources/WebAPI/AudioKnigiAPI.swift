import Foundation
import SwiftSoup
import Files

open class AudioKnigiAPI: HttpService {
  public static let SiteUrl = "https://audioknigi.club"

  let decoder = JSONDecoder()

  func getPagePath(path: String, page: Int=1) -> String {
    if page == 1 {
      return path
    }
    else {
      return "\(path)page\(page)/"
    }
  }

  public func getAuthorsLetters() throws -> [Any] {
    return try getLetters(path: "/authors/", filter: "author-prefix-filter")
  }

  public func getPerformersLetters() throws -> [Any] {
    return try getLetters(path: "/performers/", filter: "performer-prefix-filter")
  }

  public func getAuthorsLetters2(error: @escaping (Error) -> Void = { data in },
                                 success: @escaping ([Any]) throws -> Void = { data in }) throws {
    func onServiceCall(data: Data) {
      do {
        let result = try buildLetters(data, filter: "author-prefix-filter")

        try success(result)
      }
      catch let e {
        error(e)
      }
    }

    httpRequest2(AudioKnigiAPI.SiteUrl + "/authors/", success: onServiceCall, error: error)
  }

  func getLetters(path: String, filter: String) throws -> [Any] {
    let data = httpRequest(AudioKnigiAPI.SiteUrl + path)?.data

    return try buildLetters(data!, filter: filter)
  }

  func buildLetters(_ data: Data, filter: String) throws -> [Any] {
    var result = [Any]()

    let document = try toDocument(data)

    let items = try document!.select("ul[id='" + filter + "'] li a")

    for item in items.array() {
      let name = try item.text()

      result.append(name)
    }

    return result
  }

  public func getNewBooks(page: Int=1) throws -> [String: Any] {
    return try getBooks(path: "/index/", page: page)
  }

  public func getBestBooks(period: String, page: Int=1) throws -> [String: Any] {
    return try getBooks(path: "/index/views/", period: period, page: page)
  }

  public func getBooks(path: String, period: String="", page: Int=1) throws -> [String: Any] {
    let encodedPath = path.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    var pagePath = getPagePath(path: encodedPath, page: page)

    if !period.isEmpty {
      pagePath = "\(pagePath)?period=\(period)"
    }

    if let document = try fetchDocument(AudioKnigiAPI.SiteUrl + pagePath) {
      return try getBookItems(document, path: encodedPath, page: page)
    }
    else {
      return [:]
    }
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

      data.append(["type": "book", "id": href, "name": name, "thumb": thumb, "description": description ])
    }

    let paginationData = try extractPaginationData(document: document, path: path, page: page)

    return ["movies": data, "pagination": paginationData]
  }

  public func getAuthors(page: Int=1) throws -> [String: Any] {
    return try getCollection(path: "/authors/", page: page)
  }

  public func getPerformers(page: Int=1) throws -> [String: Any] {
    return try getCollection(path: "/performers/", page: page)
  }

  func getCollection(path: String, page: Int=1) throws -> [String: Any] {
    var data = [Any]()
    var paginationData = [String: Any]()

    let pagePath = getPagePath(path: path, page: page)

    if let document = try fetchDocument(AudioKnigiAPI.SiteUrl + pagePath) {
      let items = try document.select("td[class=cell-name]")

      for item: Element in items.array() {
        let link = try item.select("h4 a")
        let name = try link.text()
        let href = try link.attr("href")
        let thumb = "https://audioknigi.club/templates/skin/aclub/images/avatar_blog_48x48.png"
        //try link.select("img").attr("src")

        let index = href.index(href.startIndex, offsetBy: AudioKnigiAPI.SiteUrl.count)

        let id = String(href[index ..< href.endIndex]) + "/"
        let filteredId = id.removingPercentEncoding!

        data.append(["type": "collection", "id": filteredId, "name": name, "thumb": thumb])
      }

      if !items.array().isEmpty {
        paginationData = try extractPaginationData(document: document, path: path, page: page)
      }
    }

    return ["movies": data, "pagination": paginationData]
  }

  public func getGenres(page: Int=1) throws -> [String: Any] {
    var data = [Any]()
    var paginationData = ItemsList()

    let path = "/sections/"

    let pagePath = getPagePath(path: path, page: page)

    if let document = try fetchDocument(AudioKnigiAPI.SiteUrl + pagePath) {
      let items = try document.select("td[class=cell-name]")

      for item: Element in items.array() {
        let link = try item.select("a")
        let name = try item.select("h4 a").text()
        let href = try link.attr("href")

        let index = href.index(href.startIndex, offsetBy: AudioKnigiAPI.SiteUrl.count)

        let id = String(href[index ..< href.endIndex])

        let thumb = try link.select("img").attr("src")

        data.append(["type": "genre", "id": id, "name": name, "thumb": thumb])
      }

      if !items.array().isEmpty {
        paginationData = try extractPaginationData(document: document, path: path, page: page)
      }
    }

    return ["movies": data, "pagination": paginationData]
  }

  func getGenre(path: String, page: Int=1) throws -> [String: Any] {
    return try getBooks(path: path, page: page)
  }

  func extractPaginationData(document: Document, path: String, page: Int) throws -> ItemsList {
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

          let index1 = link.find("page")
          let index2 = link.find("?")

          let index3 = link.index(index1!, offsetBy: "page".count)
          var index4: String.Index?

          if index2 == nil {
            index4 = link.index(link.endIndex, offsetBy: -1)
          }
          else {
            index4 = link.index(index2!, offsetBy: -1)
          }

          pages = Int(link[index3..<index4!])!
        }
        else {
          pages = try Int(lastLink.text())!
        }
      }
      else {
//        let href = try items.attr("href")
//
//        let pattern = path + "page"
//
//        let index1 = href.find(pattern)
//        let index2 = href.find("/?")

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

  public func search(_ query: String, page: Int=1) throws -> [String: Any] {
    let path = "/search/books/"

    let pagePath = getPagePath(path: path, page: page)

    var params = [String: String]()
    params["q"] = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    let fullPath = buildUrl(path: pagePath, params: params as [String: AnyObject])

    if let document = try fetchDocument(AudioKnigiAPI.SiteUrl + fullPath) {
      return try getBookItems(document, path: path, page: page)
    }
    else {
      return [:]
    }
  }

  public func getAudioTracks(_ url: String) throws -> [Track] {
    var bookId = 0

    if let document = try fetchDocument(url) {
      let scripts = try document.select("script[type='text/javascript']")

      for script in scripts {
        let scriptBody =  try script.html()

        let index = scriptBody.find("$(document).audioPlayer")

        if index != nil {
          let index1 = scriptBody.index(scriptBody.startIndex, offsetBy: "$(document).audioPlayer".count+1)
          let index2 = scriptBody.find(",")!

          bookId = Int(scriptBody[index1..<index2])!

          break
        }
      }
    }

    var newTracks = [Track]()

    if bookId > 0 {
      let newUrl = "\(AudioKnigiAPI.SiteUrl)/rest/bid/\(bookId)"

      let response = httpRequest(newUrl)

      if let data = response?.data {
        if let result = try? decoder.decode([Track].self, from: data) {
          newTracks = result
        }
      }
    }

    return newTracks
  }

  public func getItemsInGroups(_ fileName: String) -> [NameClassifier.ItemsGroup] {
    var items: [NameClassifier.ItemsGroup] = []

    do {
      let data: Data? = try File(path: fileName).read()

      let decoder = JSONDecoder()

      do {
        items = try decoder.decode([NameClassifier.ItemsGroup].self, from: data!)
      }
      catch let e {
        print("Error: \(e)")
      }
    }
    catch let e {
      print("Error: \(e)")
    }

    return items
  }

}
