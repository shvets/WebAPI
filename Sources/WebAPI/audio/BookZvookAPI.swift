import Foundation
import SwiftSoup
import Alamofire
import RxSwift

open class BookZvookAPI: HttpService {
  public static let SiteUrl = "http://bookzvuk.ru/"
  public static let ArchiveUrl = "https://archive.org"

  let decoder = JSONDecoder()

  public func getDocument(_ url: String) throws -> Document? {
    return try fetchDocument(url)
  }

  public func searchDocument(_ url: String, parameters: [String: String]) throws -> Document? {
    return try fetchDocument(url, headers: [:], parameters: parameters, method: .post)
  }

  public func getLetters() throws -> [[String: String]] {
    var data = [[String: String]]()

    if let document = try getDocument(BookZvookAPI.SiteUrl) {
      let items = try document.select("div[class=textwidget] div[class=newsa_story] b span span a")

      for item in items.array() {
        let name = try item.text()

        let href = try item.attr("href")

        data.append(["id": href, "name": name.uppercased()])
      }
    }

    return data
  }

  public func getAuthorsByLetter(_ url: String) throws -> [String: [[String: String]]] {
    var data: [String: [[String: String]]] = [:]

    if let document = try getDocument(url) {
      let table = try document.select("div[id=main-col] div[id=content] article div[class=entry-container fix] table")

      let links = try table.select("tr td span a")

      for link in links.array() {
        let parent = link.parent()!.parent()!.parent()!

        var author = try parent.select("p > b > span").text()
        
        if author.isEmpty {
          author = try parent.select("b > span").text()
        }
        
        let href = try link.select("a").attr("href")
        let name = try link.select("a").text()

        let book = ["name": name, "href": href]

        var element = data[author]

        if element == nil {
          element = []
        }

        element!.append(book)

        data[author] = element!
      }
    }

    return data
  }

  public func getPlaylistUrls(_ url: String) throws -> [String] {
    var data = [String]()

    if let document = try getDocument(url) {
      let link = try document.select("iframe").attr("src")
      
      let index1 = link.index(link.startIndex, offsetBy: (BookZvookAPI.ArchiveUrl + "/embed/").count)
      let index2 = link.find("&playlist=1")
      
      if let index2 = index2 {
        let path = link[index1..<index2]

        data.append(BookZvookAPI.ArchiveUrl + "/details/" + path)
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

  public func search(_ query: String, page: Int=1) throws -> [[String: String]] {
    var data = [[String: String]]()

    let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    
    let url = BookZvookAPI.SiteUrl

    if let document = try searchDocument(url, parameters: ["s": encodedQuery]) {
      let items = try document.select("div[id=main-col] div[id=content] article")

      for item in items.array() {
        let link = try item.select("header div h2 a")

        let thumb = try item.select("div[class=entry-container fix] div p img").attr("src")

        let description = try item.select("div[class=entry-container fix] div").text()

        let href = try link.attr("href")
        
        let name = try link.text()

        data.append(["type": "book", "id": href, "name": name, "thumb": thumb, "description": description])
      }
    }

    return data
  }

}
