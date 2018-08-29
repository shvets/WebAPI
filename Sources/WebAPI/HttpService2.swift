import Foundation
import SwiftSoup

open class HttpService2 {
  public func httpRequest(_ url: String,
                          headers: [String: String] = [:],
                          parameters: [String: String] = [:],
                          method: String = "GET") -> Data? {
//    var dataResponse: DataResponse<Data>?
//
//    if let sessionManager = sessionManager {
//      let utilityQueue = DispatchQueue.global(qos: .utility)
//      let semaphore = DispatchSemaphore.init(value: 0)
//
//      sessionManager.request(url, method: method, parameters: parameters,
//        headers: headers).validate().responseData(queue: utilityQueue) { response in
//        dataResponse = response
//
//        switch response.result {
//        case .success:
//          //print("success")
//
//          if let response = response.response {
//            print("Status: \(response.statusCode)")
//          }
//
//        case .failure:
//          print("Status: failure")
//        }
//
//        semaphore.signal()
//      }
//
//      //debugPrint(request)
//
//      _ = semaphore.wait(timeout: DispatchTime.distantFuture)
//    }
//
//    return dataResponse

    var urlResponse: Data?
    //httpRequest(url, headers: headers, parameters: parameters, method: method)

    // print(response!.response!.allHeaderFields)

    let url = URL(string: url)
    var request = URLRequest(url: url!)

    for var (key, value) in headers {
      request.setValue(key, forHTTPHeaderField: value)
    }

    //let session = URLSession(configuration: .default)

    request.httpMethod = "GET"

    let semaphore = DispatchSemaphore(value: 0)

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      print(error)
      print(data)

      urlResponse = data

      semaphore.signal()
    }

    task.resume()

    semaphore.wait()

    return urlResponse
  }

  public func fetchDocument(_ url: String,
                            headers: [String: String] = [:],
                            parameters: [String: String] = [:],
                            method: String = "GET",
                            encoding: String.Encoding = .utf8) throws -> Document? {
    var document: Document?

    if let dataResponse = httpRequest(url, headers: headers, parameters: parameters, method: method),
       let html = String(data: dataResponse, encoding: encoding) {
      document = try SwiftSoup.parse(html)
    }

    return document
  }

//  public func httpRequest(url: String, headers: [String: String] = [:], query: [String: String] = [:],
//                          data: [String: String] = [:], method: String? = "get") {
////    var response: HTTPResult
//
////    let networking = Networking(baseURL: url)
////
////    networking.get("/get") { result in
////      switch result {
////      case .success(let response):
////        let json = response.dictionaryBody
////        // Do something with JSON, you can also get arrayBody
////      case .failure(let response):
////        print(response)
////        // Handle error
////      }
////    }
//
////    if method == "get" {
////      response = SwiftHTTP.GET(url, params: query, headers: headers)
////    }
////    else if method == "post" {
////      response = SwiftHTTP.POST(url, params: query, data: data, headers: headers)
////    }
////    else if method == "put" {
////      response = SwiftHTTP.PUT(url, params: query, data: data, headers: headers)
////    }
////    else if method == "delete" {
////      response = SwiftHTTP.DELETE(url, params: query, data: data, headers: headers)
////    }
////    else {
////      response = SwiftHTTP.GET(url, params: query, headers: headers)
////    }
//
//    //return response
//  }

//  public func buildUrl(path: String, params: [String: AnyObject] = [:]) -> String {
//    let paramsArray = params.map { (key, value) -> String in
//      return "\(key)=\(value)"
//    }
//
//    var url = path
//
//    if !paramsArray.isEmpty {
//      url += "?" + paramsArray.joined(separator: "&")
//    }
//
//    return url
//  }
//
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
//    let data = httpRequest(url: url).content
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
//
//  func getBaseUrl(_ url: String) -> String {
//    var pathComponents = url.components(separatedBy: "/")
//
//    return pathComponents[0...pathComponents.count-2].joined(separator: "/")
//  }

//  public func fetchDocument(_ url: String, headers: [String: String] = [:], data: [String: String] = [:],
//                            method: String?="get", encoding: String.Encoding=String.Encoding.utf8) throws -> Document? {
//    let content = fetchContent(url, headers: headers, data: data, method: method)
//
//    return try toDocument(content, encoding: encoding)
//  }
//
//  public func fetchContent(_ url: String, headers: [String: String] = [:], data: [String: String] = [:],
//                           method: String?="get") -> Data? {
//    return httpRequest(url: url, headers: headers, data: data, method: method).content
//  }
//
//  public func toDocument(_ data: Data?, encoding: String.Encoding=String.Encoding.utf8) throws -> Document? {
//    return try SwiftSoup.parse(toString(data, encoding: encoding)!)
//  }
//
//  public func toString(_ data: Data?, encoding: String.Encoding=String.Encoding.utf8) -> String? {
//    return String(data: data!, encoding: encoding)
//  }

}
