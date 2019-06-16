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

    let paginationRoot = try document.select("ul[class='pagination']")

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

//  public func getCookie(url: String, headers: HTTPHeaders) -> String? {
//    let response: DataResponse<Data>? = httpRequest(url, headers: headers)
//
//    return response?.response?.allHeaderFields["Set-Cookie"] as? String
//  }

  public func getAudioTracks(_ url: String) throws -> Observable<[Track]> {
    let (cookie, response) = getCookie()

    var security_ls_key = ""

    if let document = try self.toDocument(response?.data!) {
      let scripts = try document.select("script")

      for script in scripts {
        let text = try script.html()

        if let securityLsKey = try self.getSecurityLsKey(text: text) {
          security_ls_key = securityLsKey
        }
      }
    }

    return httpRequestRx(url).map { data in
      if let document = try self.toDocument(data) {
        var bookId = 0

        if let id = try self.getBookId(document: document) {
          bookId = id
        }

        let data = self.getData(bid: bookId, security_ls_key: security_ls_key)

        let newUrl = "\(AudioKnigiAPI.SiteUrl)/ajax/bid/\(bookId)"

        var newTracks = [Track]()

        if let cookie = cookie {
          newTracks = self.postRequest(url: newUrl, body: data, cookie: cookie)
        }

        return newTracks
      }

      return []
    }
  }

  func getCookie() -> (String?, DataResponse<Data>?)  {
    let headers: HTTPHeaders = [
      "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36"
    ];

    let response: DataResponse<Data>? = httpRequest(AudioKnigiAPI.SiteUrl, headers: headers)

    var cookie: String?

    for c in HTTPCookieStorage.shared.cookies! {
      if c.name == "PHPSESSID" {
        cookie = "\(c)"
      }
    }

    return (cookie, response)
  }

  func getBookId(document: Document) throws -> Int? {
    let items = try document.select("div[class=player-side js-topic-player]")

    let globalId = try items.first()!.attr("data-global-id")

    return Int(globalId)
  }

  func getSecurityLsKey(text: String) throws -> String? {
    var security_ls_key: String?

    let pattern = ",(LIVESTREET_SECURITY_KEY\\s+=\\s+'.*'),"

    let regex = try NSRegularExpression(pattern: pattern)

    let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))

    let match = self.getMatched(text, matches: matches, index: 1)

    if let match = match, !match.isEmpty {
      let index = match.find("'")!
      let index1 = match.index(index, offsetBy: 1)
      let index2 = match.find("',")!

      security_ls_key = String(match[index1..<index2])
    }

    return security_ls_key
  }

  func getData(bid: Int, security_ls_key: String) -> String {
    let secretPassphrase = "EKxtcg46V";

    let AES = CryptoJS.AES()

    let encrypted = AES.encrypt("\"" + security_ls_key + "\"", password: secretPassphrase)

    let ct = encrypted[0]
    let iv = encrypted[1]
    let salt = encrypted[2]

    let hashString = "{" +
      "\"ct\":\"" + ct + "\"," +
      "\"iv\":\"" + iv + "\"," +
      "\"s\":\"" + salt + "\"" +
      "}"

    let hash = hashString
      .replacingOccurrences(of: "{", with: "%7B")
      .replacingOccurrences(of: "}", with: "%7D")
      .replacingOccurrences(of: ",", with: "%2C")
      .replacingOccurrences(of: "/", with: "%2F")
      .replacingOccurrences(of: "\"", with: "%22")
      .replacingOccurrences(of: ":", with: "%3A")
      .replacingOccurrences(of: "+", with: "%2B")

    return "bid=\(bid)&hash=\(hash)&security_ls_key=\(security_ls_key)"
  }

  func postRequest(url: String, body: String, cookie: String) -> [Track] {
    print(url)
    var newTracks = [Track]()

    var request = URLRequest(url: URL(string: url)!)

    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
    request.setValue(cookie, forHTTPHeaderField: "cookie")
    request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36",
      forHTTPHeaderField: "user-agent")

    request.httpBody = body.data(using: .utf8, allowLossyConversion: false)!

    let semaphore = DispatchSemaphore.init(value: 0)

    let utilityQueue = DispatchQueue.global(qos: .utility)

    Alamofire.request(request).responseData(queue: utilityQueue) { (response) in
      if let data = response.data {
        if let result = try? data.decoded() as Tracks {
          let result2 = result.aItems

          let data3 = result2.data(using: .utf8)!

          if let result3 = try? data3.decoded() as [Track] {
            newTracks = result3
          }
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
