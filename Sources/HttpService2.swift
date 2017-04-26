import Foundation
import SwiftSoup
import Alamofire

open class HttpService2 {
  let sessionManager: SessionManager!

  public init() {
    let configuration = URLSessionConfiguration.default

    let proxyPort = 3130
    let proxyURL = "176.221.42.213"

    configuration.connectionProxyDictionary = [
      kCFNetworkProxiesHTTPEnable as AnyHashable : true,
      kCFNetworkProxiesHTTPPort as AnyHashable : proxyPort,
      kCFNetworkProxiesHTTPProxy as AnyHashable : proxyURL
    ]

    sessionManager = Alamofire.SessionManager(configuration: configuration)
  }

  public func httpRequest(_ url: String,
                        headers: HTTPHeaders = [:],
                        parameters: Parameters = [:],
                        method: HTTPMethod = .get) -> DefaultDataResponse? {
    var response: DefaultDataResponse?

    let utilityQueue = DispatchQueue.global(qos: .utility)
    let semaphore = DispatchSemaphore.init(value: 0)

    sessionManager.request(url, method: method, parameters: parameters,
        headers: headers).response(queue: utilityQueue) { resp in
      response = resp

      semaphore.signal()
    }

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)

    return response
  }

  public func fetchData(_ url: String,
                        headers: HTTPHeaders = [:],
                        parameters: Parameters = [:],
                        method: HTTPMethod = .get) -> Data? {
    let response: DefaultDataResponse? = httpRequest(url, headers: headers, parameters: parameters, method: method)

    return response?.data
  }

  public func fetchDocument(_ url: String,
                            headers: HTTPHeaders = [:],
                            parameters: Parameters = [:],
                            method: HTTPMethod = .get,
                            encoding: String.Encoding = .utf8) throws -> Document? {
    var document: Document?

    if let data = fetchData(url, headers: headers, parameters: parameters, method: method),
       let html = String(data: data, encoding: encoding) {
      document = try SwiftSoup.parse(html)
    }

    return document
  }

  public func toDocument(_ data: Data?, encoding: String.Encoding = .utf8) throws -> Document? {
    var document: Document?

    if let data = data,
       let html = String(data: data, encoding: encoding) {
      document = try SwiftSoup.parse(html)
    }

    return document
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

    var newLines = [String]()

    if let data = fetchData(url),
       let content = String(data: data, encoding: .utf8) {

      content.enumerateLines {(line, _) in
        if line[line.startIndex] == "#" {
          newLines.append(line)
        }
        else {
          newLines.append(localBaseUrl + "/" + line)
        }
      }
    }

    return newLines.joined(separator: "\n")
  }

  func getBaseUrl(_ url: String) -> String {
    var pathComponents = url.components(separatedBy: "/")

    return pathComponents[0...pathComponents.count-2].joined(separator: "/")
  }
}
