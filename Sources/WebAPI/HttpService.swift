import Foundation
import SwiftSoup
import Alamofire
import RxSwift

open class HttpService {
  let sessionManager: SessionManager?
  
  public init(proxy: Bool=false) {
    let configuration = URLSessionConfiguration.default

//    if proxy {
//      let proxyPort = 3130
//      let proxyURL = "176.221.42.213"
//
//      //      let proxyPort = 3128
//      //      let proxyURL = "93.104.210.29"
//
//      configuration.connectionProxyDictionary = [
//        kCFNetworkProxiesHTTPEnable as AnyHashable: true,
//        kCFNetworkProxiesHTTPPort as AnyHashable: proxyPort,
//        kCFNetworkProxiesHTTPProxy as AnyHashable: proxyURL
//      ]
//    }

    sessionManager = Alamofire.SessionManager(configuration: configuration)
  }
  
  public func httpRequest(_ url: String,
                          headers: HTTPHeaders = [:],
                          parameters: Parameters = [:],
                          method: HTTPMethod = .get) -> DataResponse<Data>? {
    var dataResponse: DataResponse<Data>?
    
    if let sessionManager = sessionManager {
      let utilityQueue = DispatchQueue.global(qos: .utility)
      let semaphore = DispatchSemaphore.init(value: 0)
      
      sessionManager.request(url, method: method, parameters: parameters,
         headers: headers).validate().responseData(queue: utilityQueue) { response in
          dataResponse = response
          
          switch response.result {
            case .success:
              //print("success")

              if let response = response.response {
                print("Status: \(response.statusCode)")
              }

            case .failure:
              print("Status: failure")
          }

          semaphore.signal()
      }
      
      //debugPrint(request)
      
      _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    return dataResponse
  }
  
  public func httpRequestRx(_ url: String,
                            headers: HTTPHeaders = [:],
                            parameters: Parameters = [:],
                            method: HTTPMethod = .get) -> Observable<Data> {
     return Observable.create { observer in
      if let sessionManager = self.sessionManager {
        let utilityQueue = DispatchQueue.global(qos: .utility)
        
        let request = sessionManager.request(url, method: method, parameters: parameters,
                        headers: headers).validate().responseData(queue: utilityQueue) { response in
        switch response.result {
          case .success(let value):
            observer.onNext(value)
            observer.onCompleted()
          
          case .failure(let error):
            observer.onError(error)
          }
        }
        
        return Disposables.create(with: request.cancel)
      }
      
      return Disposables.create()
    }
  }

  public func fetchDataResponse(_ url: String,
                        headers: HTTPHeaders = [:],
                        parameters: Parameters = [:],
                        method: HTTPMethod = .get) -> DataResponse<Data>? {
    let response: DataResponse<Data>? = httpRequest(url, headers: headers, parameters: parameters, method: method)

    // print(response!.response!.allHeaderFields)

    return response
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
    
    if let dataResponse = fetchDataResponse(url, headers: headers, parameters: parameters, method: method),
      let data = dataResponse.data,
      let html = String(data: data, encoding: encoding) {

      // print(html)

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
