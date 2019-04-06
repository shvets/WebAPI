import XCTest
import SwiftSoup
import Alamofire

@testable import WebAPI

class GidOnlineAPITests: XCTestCase {
//  var subject = GidOnlineAPI()
//
//  var document: Document?
//
//  var allMovies: [[String :Any]]?
//
//  override func setUp() {
//    super.setUp()
//
//    do {
//      document = try subject.fetchDocument(GidOnlineAPI.SiteUrl)
//    }
//    catch {
//      print("Error fetching document")
//    }
//  }
//
////  override func tearDown() {
////    super.tearDown()
////  }
//
//  func testGetGenres() throws {
//    let result = try subject.getGenres(document!)
//
//    print(result as Any)
//  }
//
//  func testGetTopLinks() throws {
//    let result = try subject.getTopLinks(document!)
//
//    print(result as Any)
//  }
//
//  func testGetActors() throws {
//    let result = try subject.getActors(document!)
//
//    print(result as Any)
//  }
//
//  func testGetActorsByLetter() throws {
//    let result = try subject.getActors(document!, letter: "А")
//
//    print(result as Any)
//  }
//
//  func testGetDirectors() throws {
//    let result = try subject.getDirectors(document!)
//
//    print(result as Any)
//  }
//
//  func testGetDirectorsByLetter() throws {
//    let result = try subject.getDirectors(document!, letter: "В")
//
//    print(result as Any)
//  }
//
//  func testGetCountries() throws {
//    let result = try subject.getCountries(document!)
//
//    print(result as Any)
//  }
//
//  func testGetYears() throws {
//    let result = try subject.getYears(document!)
//
//    print(result as Any)
//  }
//
//  func testGetSeasons() throws {
//    let result = try subject.getSeasons("\(GidOnlineAPI.SiteUrl)/2016/03/strazhi-galaktiki/", parentName: "parentName")
//
//    print(result as Any)
//  }
//
//  func testGetEpisodes() throws {
//    let result = try subject.getEpisodes("\(GidOnlineAPI.SiteUrl)/2016/03/strazhi-galaktiki", seasonNumber: "1")
//
//    print(result as Any)
//  }
//
//  func testGetAllMovies() throws {
//    let allMovies = try subject.getAllMovies()
//
//    print(allMovies)
//  }
//
//  func testGetMoviesByGenre() throws {
//    let document = try subject.fetchDocument(GidOnlineAPI.SiteUrl + "/genre/vestern/")
//
//    let result = try subject.getMovies(document!, path: "/genre/vestern/")
//
//    print(result as Any)
//  }
//
//  func testGetUrls() throws {
//    //let movieUrl = "http://gidonline.club/2017/02/kosmos-mezhdu-nami/"
//    let movieUrl = "http://gidvkino.club/4007-devushka-kotoraya-igrala-s-ognem.html"
//
//    let urls = try subject.getUrls(movieUrl)
//
//    print(urls)
//  }
//
//  func testDownload() throws {
//    let url = "http://185.38.12.50/sec/1494153108/383030302a6e8eab9dd7342cd960e08f8bf79e1bbd4ebd40/ivs/ae/a6/350cc47282a3/360.mp4"
//
//    let utilityQueue = DispatchQueue.global(qos: .utility)
//
//    let semaphore = DispatchSemaphore.init(value: 0)
//
//    let encodedPath = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
//
//    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
//      let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//      let fileURL = documentsURL.appendingPathComponent("downloadedFile.mp3")
//
//      return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
//    }
//
//    let configuration = URLSessionConfiguration.default
//
//    let proxyPort = 3130
//    let proxyURL = "176.221.42.213"
//
//    configuration.connectionProxyDictionary = [
//      kCFNetworkProxiesHTTPEnable as AnyHashable: true,
//      kCFNetworkProxiesHTTPPort as AnyHashable: proxyPort,
//      kCFNetworkProxiesHTTPProxy as AnyHashable: proxyURL
//    ]
//
//    let sessionManager = Alamofire.SessionManager(configuration: configuration)
//
//    sessionManager.download(encodedPath, to: destination)
//      .downloadProgress(queue: utilityQueue) { progress in
//        print("Download Progress: \(progress.fractionCompleted)")
//      }
//      .responseData(queue: utilityQueue) { response in
//        FileManager.default.createFile(atPath: "downloadedFile.mp4", contents: response.result.value)
//
//        semaphore.signal()
//      }
//
//    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
//  }
//
//  func testDownload2() throws {
//    let url = "http://streamblast.cc/video/cafa7280ceff74b7/index.m3u8"
//
//    let utilityQueue = DispatchQueue.global(qos: .utility)
//
//    let semaphore = DispatchSemaphore.init(value: 0)
//
//    //let encodedPath = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
//
//    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
//      let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//      let fileURL = documentsURL.appendingPathComponent("downloadedFile.mp3")
//
//      return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
//    }
//
//    let configuration = URLSessionConfiguration.default
//
//    let proxyPort = 3130
//    let proxyURL = "176.221.42.213"
//
//    configuration.connectionProxyDictionary = [
//      kCFNetworkProxiesHTTPEnable as AnyHashable: true,
//      kCFNetworkProxiesHTTPPort as AnyHashable: proxyPort,
//      kCFNetworkProxiesHTTPProxy as AnyHashable: proxyURL
//    ]
//
//    let sessionManager = Alamofire.SessionManager(configuration: configuration)
//
//    let parameters = [
//      "cd": "0",
//      "expired": "1494129784",
//      "frame_commit": "bd2d44bd3b8025d83a028a6b11be7c82",
//      "mw_pid": "4",
//      "signature": "3a0dc9f39d331340cf6fb20e6f0fa0bb",
//      "man_type": "zip1",
//      "eskobar": "pablo"
//    ]
//    sessionManager.download(url, parameters: parameters, to: destination)
//      .downloadProgress(queue: utilityQueue) { progress in
//        print("Download Progress: \(progress.fractionCompleted)")
//      }
//      .responseData(queue: utilityQueue) { response in
//        print(response.response?.statusCode as Any)
//        FileManager.default.createFile(atPath: "downloadedFile.txt", contents: response.result.value)
//
//        semaphore.signal()
//      }
//
//    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
//  }
//
//  func testGetSerialInfo() throws {
//    //let url = "http://gidonline.club/2016/03/strazhi-galaktiki/"
//    let url = "http://gidonline.club/2017/02/molodoj-papa/"
//
//    let result = try subject.getSerialInfo(url)
//
//    print(result as Any)
//  }
//
//  func testGetMediaData() throws {
//    let allMovies = try subject.getAllMovies()["movies"]! as! [Any]
//
//    let movieUrl = (allMovies[0] as! [String: String])["id"]!
//
//    let document = try subject.fetchDocument(movieUrl)
//
//    let result = try subject.getMediaData(document!)
//
//    print(result as Any)
//  }
//
//  func skip_testIsSerial() throws {
//    let url = "http://gidonline.club/2016/07/priklyucheniya-vudi-i-ego-druzej/"
//
//    let result = try subject.isSerial(url)
//
//    print(result as Any)
//  }
//
//  func testSearch() throws {
//    let query = "акула"
//
//    let result = try subject.search(query)
//
//    print(result as Any)
//  }
//
//  func testSearchActors() throws {
//    let query = "Аллен"
//
//    let result = try subject.searchActors(document!, query: query)
//
//    print(result as Any)
//  }
//
//  func testSearchDirectors() throws {
//    let query = "Люк"
//
//    let result = try subject.searchDirectors(document!, query: query)
//
//    print(result as Any)
//  }
//
//  func testSearchCountries() throws {
//    let query = "Франция"
//
//    let result = try subject.searchCountries(document!, query: query)
//
//    print(result as Any)
//  }
//
//  func testSearchYears() throws {
//    let query = "1984"
//
//    let result = try subject.searchYears(document!, query: query)
//
//    print(result as Any)
//  }

}
