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
      response = Just.post(url, params: query, data: query, headers: headers)
    }
    else if method == "put" {
      response = Just.put(url, params: query, data: query, headers: headers)
    }
    else if method == "delete" {
      response = Just.delete(url, params: query, data: query, headers: headers)
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
    
    if paramsArray.count > 0 {
      url += "?" + paramsArray.joined(separator: "&")
    }
    
    return url
  }

  func fetchDocument(_ url: String, headers: [String: String] = [:], encoding: String.Encoding=String.Encoding.utf8) throws -> Document? {
    let content = fetchContent(url, headers: headers)

    return try toDocument(content, encoding: encoding)
  }

  func fetchContent(_ url: String, headers: [String: String] = [:]) -> Data? {
    return httpRequest(url: url, headers: headers).content
  }

  func toDocument(_ data: Data?, encoding: String.Encoding=String.Encoding.utf8) throws -> Document? {
    return try SwiftSoup.parse(toString(data, encoding: encoding)!)
  }

  func toString(_ data: Data?, encoding: String.Encoding=String.Encoding.utf8) throws -> String? {
    return String(data: data!, encoding: encoding)
  }

}
