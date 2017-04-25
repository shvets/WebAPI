import Foundation
import SwiftSoup
import Alamofire

open class HttpService2 {
  let sessionManager = Alamofire.SessionManager.default

  public init() {}

  public func httpRequest(url: String, headers: [String: String] = [:], query: [String: String] = [:],
                          data: [String: String] = [:], method: String? = "get") -> HTTPURLResponse? {
    var response: HTTPURLResponse?

    if method == "get" {
      Alamofire.request(url).response { r in
        print(r)
//        response = r
      }
    }
//    else if method == "post" {
//      response = sessionManager.request(url, method: .post).response
//    }
//    else if method == "put" {
//      response = sessionManager.request(url, method: .put).response
//    }
//    else if method == "delete" {
//      response = sessionManager.request(url, method: .delete).response
//    }
//    else {
//      response = sessionManager.request(url, method: .get).response
//    }

    return response
  }

  public func buildUrl(path: String, params: [String: AnyObject] = [:]) -> String {
    let paramsArray = params.map { (key, value) -> String in
      return "\(key)=\(value)"
    }

    var url = path

    if !paramsArray.isEmpty {
      url += "?" + paramsArray.joined(separator: "&")
    }

    return url
  }

//  func getPlayListUrls(_ url: String) throws -> [[String: String]] {
//    var urls = [[String: String]]()
//
//    let playList = try getPlayList(url)
//
//    playList.enumerateLines {(line, _) in
//      if line[line.startIndex] != "#" {
//        urls.append(["url": line])
//      }
//    }
//
//    return urls
//  }

//  func getPlayList(_ url: String, baseUrl: String="") throws -> String {
//    var localBaseUrl = baseUrl
//
//    if localBaseUrl.isEmpty {
//      localBaseUrl = getBaseUrl(url)
//    }
//
//    let data = httpRequest(url: url)!.data
//    let content = toString(data!)
//
//    var newLines = [String]()
//
//    content!.enumerateLines {(line, _) in
//      if line[line.startIndex] == "#" {
//        newLines.append(line)
//      }
//      else {
//        newLines.append(localBaseUrl + "/" + line)
//      }
//    }
//
//    return newLines.joined(separator: "\n")
//  }

  func getBaseUrl(_ url: String) -> String {
    var pathComponents = url.components(separatedBy: "/")

    return pathComponents[0...pathComponents.count-2].joined(separator: "/")
  }

//  public func fetchDocument(_ url: String, headers: [String: String] = [:], data: [String: String] = [:],
//                            method: String?="get", encoding: String.Encoding=String.Encoding.utf8) throws -> Document? {
//    let content = fetchContent(url, headers: headers, data: data, method: method)
//
//    return try toDocument(content, encoding: encoding)
//  }

//  public func fetchContent(_ url: String, headers: [String: String] = [:], data: [String: String] = [:],
//                           method: String?="get") -> Data? {
//    return httpRequest(url: url, headers: headers, data: data, method: method)
//  }

//  public func toDocument(_ data: Data?, encoding: String.Encoding=String.Encoding.utf8) throws -> Document? {
//    return try SwiftSoup.parse(toString(data, encoding: encoding)!)
//  }
//
//  public func toString(_ data: Data?, encoding: String.Encoding=String.Encoding.utf8) -> String? {
//    return String(data: data!, encoding: encoding)
//  }

}
