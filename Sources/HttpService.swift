import Foundation
import Just
import SwiftSoup

open class HttpService {
  public init() {}
  
  public func httpRequest(url: String, headers: [String: String] = [:], query: [String: String] = [:],
                          data: [String: String] = [:], method: String? = "get") -> HTTPResult {
    var response: HTTPResult
    
    if method == "get" {
      response = Just.get(url, params: query, headers: headers)
    }
    else if method == "post" {
      response = Just.post(url, params: query, data: data, headers: headers)
    }
    else if method == "put" {
      response = Just.put(url, params: query, data: data, headers: headers)
    }
    else if method == "delete" {
      response = Just.delete(url, params: query, data: data, headers: headers)
    }
    else {
      response = Just.get(url, params: query, headers: headers)
    }
    
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

  func getPlayListUrls(_ url: String) throws -> [[String: String]] {
    var urls = [[String: String]]()

    let playList = try getPlayList(url)

    playList.enumerateLines {(line, _) in
      if line[line.startIndex] != "#" {
        urls.append(["url": line])
      }
    }

    return urls
  }

  func getPlayList(_ url: String, baseUrl: String="") throws -> String {
    var localBaseUrl = baseUrl

    if localBaseUrl.isEmpty {
      localBaseUrl = getBaseUrl(url)
    }

    let data = httpRequest(url: url).content
    let content = toString(data!)

    var newLines = [String]()

    content!.enumerateLines {(line, _) in
      if line[line.startIndex] == "#" {
        newLines.append(line)
      }
      else {
        newLines.append(localBaseUrl + "/" + line)
      }
    }

    return newLines.joined(separator: "\n")
  }

  func getBaseUrl(_ url: String) -> String {
    var pathComponents = url.components(separatedBy: "/")

    return pathComponents[0...pathComponents.count-2].joined(separator: "/")
  }

  public func fetchDocument(_ url: String, headers: [String: String] = [:], data: [String: String] = [:],
                            method: String?="get", encoding: String.Encoding=String.Encoding.utf8) throws -> Document? {
    let content = fetchContent(url, headers: headers, data: data, method: method)

    return try toDocument(content, encoding: encoding)
  }

  public func fetchContent(_ url: String, headers: [String: String] = [:], data: [String: String] = [:],
                           method: String?="get") -> Data? {
    return httpRequest(url: url, headers: headers, data: data, method: method).content
  }

  public func toDocument(_ data: Data?, encoding: String.Encoding=String.Encoding.utf8) throws -> Document? {
    return try SwiftSoup.parse(toString(data, encoding: encoding)!)
  }

  public func toString(_ data: Data?, encoding: String.Encoding=String.Encoding.utf8) -> String? {
    return String(data: data!, encoding: encoding)
  }

}
