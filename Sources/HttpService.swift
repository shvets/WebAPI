import Foundation
import SwiftSoup
import Alamofire

open class HttpService {
  let sessionManager: SessionManager!

  public init(proxy: Bool=false) {
    let configuration = URLSessionConfiguration.default

    if proxy {
      let proxyPort = 3130
      let proxyURL = "176.221.42.213"

//      let proxyPort = 3128
//      let proxyURL = "93.104.210.29"

      configuration.connectionProxyDictionary = [
        kCFNetworkProxiesHTTPEnable as AnyHashable: true,
        kCFNetworkProxiesHTTPPort as AnyHashable: proxyPort,
        kCFNetworkProxiesHTTPProxy as AnyHashable: proxyURL
      ]
    }

    sessionManager = Alamofire.SessionManager(configuration: configuration)
  }

  public func httpRequest(_ url: String,
                        headers: HTTPHeaders = [:],
                        parameters: Parameters = [:],
                        method: HTTPMethod = .get) -> DataResponse<Data>? {
    var dataResponse: DataResponse<Data>?

    let utilityQueue = DispatchQueue.global(qos: .utility)
    let semaphore = DispatchSemaphore.init(value: 0)

    sessionManager.request(url, method: method, parameters: parameters,
        headers: headers).validate().responseData(queue: utilityQueue) { response in
      dataResponse = response

      print("Status: \(response.response!.statusCode)")

      semaphore.signal()
    }

    //debugPrint(request)

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)

    return dataResponse
  }

  public func httpRequest2(_ url: String,
                          headers: HTTPHeaders = [:],
                          parameters: Parameters = [:],
                          method: HTTPMethod = .get,
                          successHandler: @escaping (Data) -> Void = { data in },
                          errorHandler: @escaping (Error) -> Void = { data in }) {
    sessionManager.request(url, method: method, parameters: parameters,
        headers: headers).validate().responseData { response in

      switch response.result {
        case .success(let data):
          DispatchQueue.main.async {
            successHandler(data)
          }

        case .failure(let error):
          DispatchQueue.main.async {
            errorHandler(error)
          }
      }
    }
  }

  public func fetchData(_ url: String,
                        headers: HTTPHeaders = [:],
                        parameters: Parameters = [:],
                        method: HTTPMethod = .get) -> Data? {
    let response: DataResponse<Data>? = httpRequest(url, headers: headers, parameters: parameters, method: method)

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
