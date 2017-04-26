import Foundation
import SwiftyJSON
import SwiftSoup
import Unbox

open class AudioBooAPI: HttpService {
  public static let SiteUrl = "http://audioboo.ru"
  public static let ArchiveUrl = "https://archive.org"

  public func getDocument(_ url: String) throws -> Document? {
    return try fetchDocument(url, encoding: .windowsCP1251)
  }

  public func searchDocument(_ url: String, parameters: [String: String]) throws -> Document? {
    let headers = ["X-Requested-With": "XMLHttpRequest"]

    return try fetchDocument(url, headers: headers, parameters: parameters, method: .post, encoding: .windowsCP1251)
  }

  func getPagePath(path: String, page: Int=1) -> String {
    if page == 1 {
      return path
    }
    else {
      return "\(path)page\(page)/"
    }
  }

  func getLetters() throws -> [Any] {
    var data = [Any]()

    let document = try getDocument(AudioBooAPI.SiteUrl)

    let items = try document!.select("div[class=content] div div a[class=alfavit]")

    for item in items.array() {
      let name = try item.text()

      let href = try item.attr("href")

      data.append(["id": href, "name": name])
    }

    return data
  }

  func getAuthorsByLetter(_ path: String) throws -> [(key: String, value: [Any])] {
    var groups: [String: [NameClassifier.Item]] = [:]

    let document = try getDocument(AudioBooAPI.SiteUrl + path)

    let items = try document!.select("div[class=full-news-content] div a")

    for item in items.array() {
      let href = try item.attr("href")
      let name = try item.text().trim()

      if !name.isEmpty && !name.hasPrefix("ALIAS") && Int(name) == nil {
        let index1 = name.startIndex
        let index2 = name.index(name.startIndex, offsetBy: 3)

        let groupName = name[index1 ..< index2].uppercased()

        if !groups.keys.contains(groupName) {
          groups[groupName] = []
        }

        var group: [NameClassifier.Item] = []

        for item in groups[groupName]! {
          group.append(item)
        }

        group.append(try unbox(dictionary: ["id": href, "name": name]))

        groups[groupName] = group
      }
    }

    var newGroups: [(key: String, value: [NameClassifier.Item])] = []

    for (groupName, group) in groups {
      newGroups.append((key: groupName, value: group))
    }

    return NameClassifier().mergeSmallGroups(newGroups)
  }

  public func getBooks(_ url: String) throws -> [Any] {
    var data = [Any]()

    let document = try getDocument(url)

    let items = try document!.select("div[class=biography-main]")

    for item: Element in items.array() {
      let name = try item.select("div[class=biography-title] h2 a").text()
      let href = try item.select("div div[class=biography-image] a").attr("href")
      let thumb = try item.select("div div[class=biography-image] a img").attr("src")

      let elements = try item.select("div[class=biography-content] div").array()

      let content = try elements[0].text()
      let rating = try elements[2].select("div[class=rating] ul li[class=current-rating]").text()

      data.append(["type": "book", "id": href, "name": name, "thumb": thumb, "content": content, "rating": rating])
    }

    return data
  }

  func getPlaylistUrls(_ url: String) throws -> [Any] {
    var data = [Any]()

    let document = try getDocument(url)

    let items = try document!.select("object")

    for item: Element in items.array() {
      data.append(try item.attr("data"))
    }

    return data
  }

  public func getAudioTracks(_ url: String) throws -> [Any] {
    var data = [Any]()

    let document = try getDocument(url)

    let items = try document!.select("script")

    for item in items.array() {
      let text = try item.html()

      let index1 = text.find("Play('jw6',")
      let index2 = text.find("{\"start\":0,")

      if index1 != nil && index2 != nil {
        let content = text[text.index(index1!, offsetBy: 10) ... text.index(index2!, offsetBy: -1)].trim()

        let content2 = content[content.index(content.startIndex, offsetBy: 2) ..< content.index(content.endIndex, offsetBy: -2)]

        data.append(JSON(content2))
      }
    }

    return data
  }

  public func search(_ query: String, page: Int=1) throws -> [Any] {
    var data = [Any]()

    let url = AudioBooAPI.SiteUrl + "/engine/ajax/search.php"

    let document = try searchDocument(url, parameters: ["query": query])

    let items = try document!.select("a")

    for item in items.array() {
      let name = try item.text()

      let href = try item.attr("href")

      data.append(["id": href, "name": name])
    }

    return data
  }

}
