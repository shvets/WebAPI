import Foundation
import SwiftyJSON
import SwiftSoup
import Unbox

open class AudioBooAPI: HttpService {
  public static let SiteUrl = "http://audioboo.ru"
  public static let ArchiveUrl = "https://archive.org"
  
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

    let document = try fetchDocument(AudioBooAPI.SiteUrl)

    let items = try document!.select("div[class=content] div div a[class=alfavit]")

    for item in items.array() {
      let name = try item.text()

      let href = try item.attr("href")

      data.append(["id": href, "name": name])
    }

    return data
  }

  func getAuthorsByLetter(path: String) {

  }

  public func getBooks(url: String) throws -> [Any] {
    var data = [Any]()

    let document = try fetchDocument(url)

    let items = try document!.select("div[class=biography-main]")

    for item: Element in items.array() {
      let name = try item.select("div[class=biography-title] h2 a").text()
      let href = try item.select("div div[class=biography-image] a").attr("href")
      let thumb = try item.select("div div[class=biography-image] a img").attr("src")
      let content = try item.select("div[class=biography-content] div").text()
      let ratingNode = try item.select("div[class=biography-content] div div[class=rating] ul li")

      var rating = ""

      if ratingNode != nil {
        //rating = ratingNode.text
      }

      data.append(["type": "book", "id": href, "name": name, "thumb": thumb, "content": content, "rating": rating])
    }

    return data
  }

  func getPlaylistUrls(url: String) throws -> [Any] {
    var data = [Any]()

    let document = try fetchDocument(url)

    let items = try document!.select("object")

    for item: Element in items.array() {
      data.append(try item.select("data"))
    }

    return data
  }

  public func getAudioTracks(url: String) throws -> [Any] {
    var data = [Any]()

    let document = try fetchDocument(url)

//    let items = try document!.select("script")
//
//    for item: Element in items.array() {
//      let text = script.text()

//      index1 = text.find("Play('jw6',")
//      index2 = text.find('{"start":0,')
//
//      if index1 >= 0 && index2 >= 0 {
//        content = text[index1 + 10:index2 - 1].strip()
//
//        content = content[2:len(content) - 1].strip()
//
//        data.append(json.loads(content))
//      }
    //

//    return data[0]
    return data
  }

  public func search(_ query: String, page: Int=1) throws -> [String: Any] {
    let url = AudioBooAPI.SiteUrl + "/engine/ajax/search.php"

//    headers = {'X-Requested-With': 'XMLHttpRequest'}
//
//    content = self.http_request(url, headers=headers, data={'query': query}, method='POST').read()
//
//    document = self.to_document(content)
//
//    data = []

    var data = [String: Any]()

//
//    items = document.xpath('a')
//
//    for item in items {
//      href = item.xpath('@href')[0]
//      name = item.text_content().upper()
//
//      data.append({'path': href, 'name': name})
//    }

    return data
  }


}
