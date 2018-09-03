import Foundation
import SwiftSoup
import Files
import Alamofire
import RxSwift
import CryptoSwift

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
    return httpRequestRx(url).map { data in
      if let document = try self.toDocument(data) {
        var bookId = 0
        var security_ls_key = ""
        var session_id = ""

        let scripts = try document.select("script[type='text/javascript']")

        for script in scripts {
          let text = try script.html()

          if let id = try self.getBookId(text: text) {
            bookId = id
          }

          if let securityLsKey = try self.getSecurityLsKey(text: text) {
            security_ls_key = securityLsKey
          }

          if let sessionId = try self.getSessionId(text: text) {
            session_id = sessionId
          }
        }

        //security_ls_key = "8af4d32fcbbca394d0612bc3820e422a"

        let data = self.getData(bid: bookId, security_ls_key: security_ls_key)

        let newUrl = "\(AudioKnigiAPI.SiteUrl)/ajax/bid/\(bookId)"

        var newTracks = [Track]()

        //session_id = "n9fo46jbhr5v5lup3r3j0h0fk7"

        newTracks = self.postRequest(url: newUrl, body: data, sessionId: session_id)

        return newTracks
      }

      return []
    }
  }

  func getBookId(text: String) throws -> Int? {
    var bid: Int?

    let pattern = "\\$\\(document\\)\\.audioPlayer\\((\\d{5,7}),"

    let regex = try NSRegularExpression(pattern: pattern)

    let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))

    if let match = self.getMatched(text, matches: matches, index: 1) {
      bid = Int(match)
    }

    return bid
  }

  func getSecurityLsKey(text: String) throws -> String? {
    var security_ls_key: String?

    let pattern = "var\\s+(LIVESTREET_SECURITY_KEY\\s+=\\s+'.*');"

    let regex = try NSRegularExpression(pattern: pattern)

    let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))

    let match = self.getMatched(text, matches: matches, index: 1)

    if let match = match, !match.isEmpty {
      let index = match.find("'")!
      let index1 = match.index(index, offsetBy: 1)
      let index2 = match.find("';")!

      security_ls_key = String(match[index1..<index2])
    }

    return security_ls_key
  }

  func getSessionId(text: String) throws -> String? {
    var sessionId: String?

    let pattern = "var\\s+(SESSION_ID\\s+=\\s+'.*');"

    let regex = try NSRegularExpression(pattern: pattern)

    let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))

    let match = self.getMatched(text, matches: matches, index: 1)

    if let match = match, !match.isEmpty {
      let index = match.find("'")!
      let index1 = match.index(index, offsetBy: 1)
      let index2 = match.find("';")!

      sessionId = String(match[index1..<index2])
    }

    return sessionId
  }

  func getData(bid: Int, security_ls_key: String) -> String {
    let secretPassphrase = "EKxtcg46V";

    let AES = CryptoJS.AES()

    let encrypted = AES.encrypt("\"" + security_ls_key + "\"", password: secretPassphrase)

//    var values: [String: String] = [
//      //    var ct = encrypted.ciphertext.toString(CryptoJS.enc.Base64);
//      "ct": encrypted[0],
//      "iv": encrypted[1],
//      "s": encrypted[2]
//    ]

//    let ct = "yWrnEqz/ujnSipf6ZDUrrF2OcrhZq+Nudy9eDefd0WqF25fH4r+kuUst8mYwrbDF"
//    let iv = "2d1fb485279819b1d20ffb5f44b5a8ab"
//    let salt = "a49ca3fd98f89f27"

    let ct = encrypted[0]
    let iv = encrypted[1]
    let salt = encrypted[2]

    let hashString = "{" +
      "\"ct\":\"" + ct + "\"," +
      "\"iv\":\"" + iv + "\"," +
      "\"s\":\"" + salt + "\"" +
      "}"

    var hash = hashString
      //percentEscapeString(hashString)
      .replacingOccurrences(of: "{", with: "%7B")
      .replacingOccurrences(of: "}", with: "%7D")
      .replacingOccurrences(of: ",", with: "%2C")
      .replacingOccurrences(of: "/", with: "%2F")
      .replacingOccurrences(of: "\"", with: "%22")
      .replacingOccurrences(of: ":", with: "%3A")
      .replacingOccurrences(of: "+", with: "%2B")

    return "bid=\(bid)&hash=\(hash)&security_ls_key=\(security_ls_key)"
  }

//  private func percentEscapeString(_ string: String) -> String {
//    var characterSet = CharacterSet.alphanumerics
//    characterSet.insert(charactersIn: "-._* ")
//
//    return string
//      .addingPercentEncoding(withAllowedCharacters: characterSet)!
//      .replacingOccurrences(of: " ", with: "+")
//      .replacingOccurrences(of: " ", with: "+", options: [], range: nil)
//  }

  func postRequest(url: String, body: String, sessionId: String) -> [Track] {
    var newTracks = [Track]()

    var request = URLRequest(url: URL(string: url)!)

    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
    request.setValue("PHPSESSID=\(sessionId)", forHTTPHeaderField: "cookie")

    request.httpBody = body.data(using: .utf8, allowLossyConversion: false)!

    let semaphore = DispatchSemaphore.init(value: 0)

    Alamofire.request(request).responseData { (response) in
      if let data = response.data {
        print(String(data: data, encoding: .utf8)!)
        if let result = try? data.decoded() as Tracks {
          newTracks = result.aItems
        }
      }

      semaphore.signal()
    }

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)

    return newTracks
  }

  func getMatched(_ link: String, matches: [NSTextCheckingResult], index: Int) -> String? {
    var matched: String?

    let match = matches.first

    if let match = match, index < match.numberOfRanges {
      let capturedGroupIndex = match.range(at: index)

      let index1 = link.index(link.startIndex, offsetBy: capturedGroupIndex.location)
      let index2 = link.index(index1, offsetBy: capturedGroupIndex.length-1)

      matched = String(link[index1 ... index2])
    }

    return matched
  }

//  func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
//    var options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : nil
//    if JSONSerialization.isValidJSONObject(value) {
//      if let data = JSONSerialization.dataWithJSONObject(value, options: options!) {
//        if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
//          return string
//        }
//      }
//    }
//    return ""
//  }

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
