import Foundation
import SwiftSoup
import Files
import Alamofire
import RxSwift

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

  public func getAuthorsLetters() -> Observable<[Any]> {
    let url = AudioKnigiAPI.SiteUrl + "/authors/"

    return httpRequestRx(url).map { [weak self] data in
      return (try self?.buildLetters(data, filter: "author-prefix-filter"))!
    }
  }

  func getLetters(path: String, filter: String) throws -> Observable<[Any]> {
    let url = AudioKnigiAPI.SiteUrl + path

    return httpRequestRx(url).map { [weak self] data in
      return try self!.buildLetters(data, filter: filter)
    }
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

  public func getNewBooks(page: Int=1) -> Observable<[String: Any]> {
    return getBooks(path: "/index/", page: page)
  }

  public func getBestBooks(period: String, page: Int=1) -> Observable<[String: Any]> {
    return getBooks(path: "/index/views/", period: period, page: page)
  }

  public func getBooks(path: String, period: String="", page: Int=1) -> Observable<[String: Any]> {
    let encodedPath = path.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    var pagePath = getPagePath(path: encodedPath, page: page)

    if !period.isEmpty {
      pagePath = "\(pagePath)?period=\(period)"
    }

    let url = AudioKnigiAPI.SiteUrl + pagePath

    return httpRequestRx(url).map { data in
      if let document = try self.toDocument(data) {
        return try self.getBookItems(document, path: encodedPath, page: page)
      }

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

  public func getAuthors(page: Int=1) -> Observable<[String: Any]> {
    return getCollection(path: "/authors/", page: page)
  }

  public func getPerformers(page: Int=1) -> Observable<[String: Any]> {
    return getCollection(path: "/performers/", page: page)
  }

  func getCollection(path: String, page: Int=1) -> Observable<[String: Any]> {
    var collection = [Any]()
    var paginationData = [String: Any]()

    let pagePath = getPagePath(path: path, page: page)

    let url = AudioKnigiAPI.SiteUrl + pagePath

    return httpRequestRx(url).map { data in
      if let document = try self.toDocument(data) {
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

          collection.append(["type": "collection", "id": filteredId, "name": name, "thumb": thumb])
        }

        if !items.array().isEmpty {
          paginationData = try self.extractPaginationData(document: document, path: path, page: page)
        }

        return ["movies": collection, "pagination": paginationData]
      }

      return [:]
    }
  }

  public func getGenres(page: Int=1) -> Observable<[String: Any]> {
    let path = "/sections/"

    let pagePath = getPagePath(path: path, page: page)

    let url = AudioKnigiAPI.SiteUrl + pagePath

    return httpRequestRx(url).map { data in
      if let document = try self.toDocument(data) {
        var data = [Any]()
        var paginationData = ItemsList()

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
          paginationData = try self.extractPaginationData(document: document, path: path, page: page)
        }

        return ["movies": data, "pagination": paginationData]
      }

      return [:]
    }
  }

  func getGenre(path: String, page: Int=1) -> Observable<[String: Any]> {
    return getBooks(path: path, page: page)
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

  public func search(_ query: String, page: Int=1) -> Observable<[String: Any]> {
    let path = "/search/books/"

    let pagePath = getPagePath(path: path, page: page)

    var params = [String: String]()
    params["q"] = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    let fullPath = buildUrl(path: pagePath, params: params as [String: AnyObject])

    let url = AudioKnigiAPI.SiteUrl + fullPath

    return httpRequestRx(url).map { data in
      if let document = try self.toDocument(data) {
        return try self.getBookItems(document, path: path, page: page)
      }

      return [:]
    }
  }

  public func getAudioTracks(_ url: String) -> Observable<[Track]> {
    var bookId = 0

    return httpRequestRx(url).map { data in
      if let document = try self.toDocument(data) {
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

        var newTracks = [Track]()

//        if bookId > 0 {
//          let newUrl = "\(AudioKnigiAPI.SiteUrl)/rest/bid/\(bookId)"
//
//          let response = self.httpRequest(newUrl)
//
//          if let data = response?.data {
//            if let result = try? data.decoded() as [Track] {
//              newTracks = result
//            }
//          }
//        }

        if bookId > 0 {
          let newUrl = "\(AudioKnigiAPI.SiteUrl)/ajax/bid/\(bookId)"

          let headers: [String: String] = [
            ":authority": "audioknigi.club",
            ":method": "POST",
            ":path": "/ajax/bid/40239",
            ":scheme": "https",
            "accept": "application/json, text/javascript,*/*; q=0.01",
            "x-requested-with": "XMLHttpRequest",
            "origin": "https://audioknigi.club",
            "referer": "https://audioknigi.club/alekseev-gleb-povesti-i-rasskazy",
            "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
            "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36"
          ]

          let searchData: [String: Any] = [
            "bid": "40239",
//            "hash": [
//              "ct": "tBggIjTxT0zhj2AxPwT8Rf5vhT/h+8h4UKZTQJFzJb3gUSCjei850cr4tOFWy8kE",
//              "iv": "9fdc5aaecec5c1eda7c5b210429a9ac5",
//              "s": "30baf43c094939bc"
//            ],
            "security_ls_key": "2da673262dfeb2bda4a66d68335f0804"
          ]

          let response = self.httpRequest(newUrl, headers: headers, parameters: searchData, method: .post)

          if let data = response?.data {
            print(String(data: data, encoding: .utf8))
            if let result = try? data.decoded() as Tracks {
              newTracks = result.aItems
            }
          }
        }

        return newTracks
      }

      return []
    }
  }

  public func getItemsInGroups(_ fileName: String) -> [NameClassifier.ItemsGroup] {
    var items: [NameClassifier.ItemsGroup] = []

    do {
      let data: Data? = try File(path: fileName).read()

      do {
        items = try data!.decoded() as [NameClassifier.ItemsGroup]
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
