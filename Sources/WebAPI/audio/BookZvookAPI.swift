import Foundation
import SwiftSoup
import Alamofire
import RxSwift

open class BookZvookAPI: HttpService {
  public static let SiteUrl = "http://bookzvuk.ru/"
  public static let ArchiveUrl = "https://archive.org"

  let decoder = JSONDecoder()

  func getPagePath(path: String, page: Int=1) -> String {
    if page == 1 {
      return path
    }
    else {
      return "\(path)page/\(page)/"
    }
  }

  public func getPopularBooks() throws -> Observable<[[String: String]]> {
    var data = [[String: String]]()

    return httpRequestRx(BookZvookAPI.SiteUrl).map { [weak self] rawData in
      if let document = try self!.toDocument(rawData) {
        let items = try document.select("div[class=textwidget] > div > a")

        for item in items.array() {
          let name = try item.select("img").attr("alt")
          let href = try item.attr("href")
          let thumb = try item.select("img").attr("src")

          data.append(["id": href, "name": name, "thumb": thumb])
        }

        return data
      }

      return []
    }
  }

  public func getLetters() throws -> Observable<[[String: String]]> {
    var data = [[String: String]]()

    return httpRequestRx(BookZvookAPI.SiteUrl).map { [weak self] rawData in
      if let document = try self!.toDocument(rawData) {
        let items = try document.select("div[class=textwidget] div[class=newsa_story] b span span a")

        for item in items.array() {
          let name = try item.text()
          let href = try item.attr("href")

          data.append(["id": href, "name": name.uppercased()])
        }

        return data
      }

      return []
    }
  }

  public func getAuthorsByLetter(_ url: String) throws -> [Author] {
    var data: [Author] = []

    if let document = try fetchDocument(url) {
      data = try AuthorsBuilder().build(document: document)
    }

    return data
  }

  public func getAuthors(_ url: String) throws -> [[String: String]] {
    var list: [[String: String]] = []

    let authors = try getAuthorsByLetter(url)

    for (author) in authors {
      list.append(["name": author.name])
    }

    return list
  }

  public func getAuthorBooks(_ url: String, name: String, page: Int=1, perPage: Int=10) throws -> [String: Any] {
    var data: [Book] = []

    let authors = try getAuthorsByLetter(url)

    for (author) in authors {
      if author.name == name {
        data = author.books
        break
      }
    }

    var items: [Any] = []

    for (index, item) in data.enumerated() {
      if index >= (page-1)*perPage && index < page*perPage {
        items.append(item)
      }
    }

    let pagination = buildPaginationData(data, page: page, perPage: perPage)

    return ["movies": items, "pagination": pagination]
  }

  func buildPaginationData(_ data: [Any], page: Int, perPage: Int) -> [String: Any] {
    let pages = data.count / perPage

    return [
      "page": page,
      "pages": pages,
      "has_next": page < pages,
      "has_previous": page > 1
    ]
  }

  public func getGenres() throws -> [[String: String]] {
    var data = [[String: String]]()

    if let document = try fetchDocument(BookZvookAPI.SiteUrl) {
      let items = try document.select("aside[id=categories-2] div[class=dbx-content] ul li a")

      for item in items.array() {
        let name = try item.text()
        let href = try item.attr("href")

        data.append(["id": href, "name": name])
      }
    }

    return data
  }

  public func getPlaylistUrls(_ url: String) throws -> [String] {
    var data = [String]()

    if let document = try fetchDocument(url) {
      let link = try document.select("iframe").attr("src")
      
      if !link.isEmpty {
        let index1 = link.index(link.startIndex, offsetBy: (BookZvookAPI.ArchiveUrl + "/embed").count)
        let index2 = link.find("&playlist=1")
        
        if let index2 = index2 {
          let path = link[index1..<index2]
          
          data.append(BookZvookAPI.ArchiveUrl + "/details/" + path)
        }
      }
    }

    return data
  }

  public func getAudioTracks(_ url: String) throws -> [BooTrack] {
    var data = [BooTrack]()

    if let document = try fetchDocument(url) {
      let items = try document.select("script")

      for item in items.array() {
        let text = try item.html()

        let index1 = text.find("Play('jw6',")
        let index2 = text.find("{\"start\":0,")

        if let index1 = index1, let index2 = index2 {
          let content = String(text[text.index(index1, offsetBy: 10) ... text.index(index2, offsetBy: -1)]).trim()
          let content2 = content[content.index(content.startIndex, offsetBy: 2) ..< content.index(content.endIndex, offsetBy: -2)]
          let content3 = content2.replacingOccurrences(of: ",", with: ", ").replacingOccurrences(of: ":", with: ": ")

          if let result = try? decoder.decode([BooTrack].self, from: content3.data(using: .utf8)!) {
            data = result
          }
        }
      }
    }

    return data
  }

  public func getNewBooks(page: Int=1) throws -> Observable<[String: Any]> {
    return try getBooks(BookZvookAPI.SiteUrl, page: page)
  }

  public func getGenreBooks(_ url: String, page: Int=1) throws -> Observable<[String: Any]> {
    return try getBooks(url, page: page)
  }

  public func getBooks(_ url: String, page: Int=1) throws -> Observable<[String: Any]> {
    var data = [Any]()
    var paginationData = ItemsList()

    let pagePath = getPagePath(path: "", page: page)

    let url = "\(url)\(pagePath)"

    return httpRequestRx(url).map { [weak self] rawData in
      if let document = try self!.toDocument(rawData) {
        let items = try document.select("div[id=main-col] div[id=content] article")

        for item in items.array() {
          data.append(try self!.getBook(item))
        }

        paginationData = try self!.extractPaginationData(document: document, path: pagePath, page: page)

        return ["movies": data, "pagination": paginationData]
      }

      return [:]
    }
  }

  public func search(_ query: String, page: Int=1) throws -> Observable<[String: Any]> {
    var data = [Any]()
    var paginationData = ItemsList()

    let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    let pagePath = getPagePath(path: "", page: page)

    let url = "\(BookZvookAPI.SiteUrl)\(pagePath)"

    return httpRequestRx(url, headers: [:], parameters: ["s": encodedQuery], method: .post).map { [weak self] rawData in
      if let document = try self!.toDocument(rawData) {
        let items = try document.select("div[id=main-col] div[id=content] article")

        for item in items.array() {
          data.append(try self!.getBook(item))
        }

        paginationData = try self!.extractPaginationData(document: document, path: pagePath, page: page)

        return ["movies": data, "pagination": paginationData]
      }

      return [:]
    }
  }

  private func getBook(_ item: Element) throws -> [String: String] {
    let link = try item.select("header div h2 a")

    let thumb = try item.select("div[class=entry-container fix] div p img").attr("src")

    let description = try item.select("div[class=entry-container fix] div").text()

    let href = try link.attr("href")

    let name = try link.text()
      .replacingOccurrences(of: "(Аудиокнига онлайн)", with: "")
      .replacingOccurrences(of: "(Аудиоспектакль онлайн)", with: "(спектакль)")
      .replacingOccurrences(of: "(Audiobook online)", with: "")

    return ["type": "book", "id": href, "name": name, "thumb": thumb, "description": description]
  }

  func extractPaginationData(document: Document, path: String, page: Int) throws -> ItemsList {
    var pages = 1

    let paginationRoot = try document.select("div[class=page-nav fix] div[class=wp-pagenavi]")

    if paginationRoot.size() > 0 {
      let paginationBlock = paginationRoot.get(0)

      let items = try paginationBlock.select("span[class=pages]").array()

      if items.count == 1 {
        let text = try items[0].text()

        if let index1 = text.find("из") {
          let index2 = text.index(index1, offsetBy: 3)

          pages = Int(text[index2..<text.endIndex])!
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

}
