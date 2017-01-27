import XCTest
import SwiftyJSON
import SwiftSoup

@testable import WebAPI

class GidOnlineAPITests: XCTestCase {
  var subject = GidOnlineAPI()

  var document: Document?

  var allMovies: [[String :Any]]?

  override func setUp() {
    super.setUp()

    do {
      document = try subject.fetchDocument(GidOnlineAPI.URL)
    }
    catch {
      print("Error fetching document")
    }
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testGetGenres() throws {
    let result = try subject.getGenres(document!)

    print(JsonConverter.prettified(result))
  }

  func testGetTopLinks() throws {
    let result = try subject.getTopLinks(document!)

    print(JsonConverter.prettified(result))
  }

  func testGetActors() throws {
    //let document = try subject.fetchDocument(GidOnlineAPI.URL)

    let result = try subject.getActors(document!)

    print(JsonConverter.prettified(result))
  }

  func testGetActorsByLetter() throws {
    let result = try subject.getActors(document!, letter: "А")

    print(JsonConverter.prettified(result))
  }

  func testGetDirectors() throws {
    let result = try subject.getDirectors(document!)

    print(JsonConverter.prettified(result))
  }

  func testGetDirectorsByLetter() throws {
    let result = try subject.getDirectors(document!, letter: "В")

    print(JsonConverter.prettified(result))
  }

  func testGetCountries() throws {
    let result = try subject.getCountries(document!)

    print(JsonConverter.prettified(result))
  }

  func testGetYears() throws {
    let result = try subject.getYears(document!)

    print(JsonConverter.prettified(result))
  }

  func testGetSeasons() throws {
    let result = try subject.getSeasons("/2016/03/strazhi-galaktiki/")

    print(JsonConverter.prettified(result))
  }

  func testGetEpisodes() throws {
    let result = try subject.getEpisodes("/2016/03/strazhi-galaktiki")

    print(JsonConverter.prettified(result))
  }

  func testGetAllMovies() throws {
    let allMovies = try subject.getAllMovies()

    print(JsonConverter.prettified(allMovies))
  }

  func testGetMoviesByGenre() throws {
    let document = try subject.fetchDocument(GidOnlineAPI.URL + "/genre/vestern/")

    let result = try subject.getMovies(document!, path: "/genre/vestern/")

    print(JsonConverter.prettified(result))
  }

  func testGetMovieUrl() throws {
    let movieUrl = "http://gidonline.club/2017/01/pravila-sema-teoriya-babnika/"

    let urls = try subject.getUrls(movieUrl)

    print(JsonConverter.prettified(urls))
  }

  func testGetSerialUrl() throws {
    let url = "http://gidonline.club/2016/03/strazhi-galaktiki/"

    let document = try subject.getMovieDocument(url)

    //print(document)
//    let serialInfo = subject.getSerialInfo(document)
//
//    print(serialInfo)

//    print(JsonConverter.prettified(urls))
  }

  func testGetPlayList() throws {
//    let movieUrl = allMovies![1]["path"] as! String
//
//    print(movieUrl)
//
//    let urls = try subject.getUrls(movieUrl)
//
//    print(JsonConverter.prettified(urls))
//
//    let result = try subject.getPlayList(urls[2]["url"])
//
//    print(JsonConverter.prettified(result))
  }

  func testGetMediaData() throws {
    let allMovies = try subject.getAllMovies()["items"]! as! [Any]

    let movieUrl = (allMovies[0] as! [String: String])["id"]!

    let document = try subject.fetchDocument(movieUrl)

    let result = try subject.getMediaData(document!)

    print(JsonConverter.prettified(result))
  }

  func testGetSerialInfo() throws {
//    let movieUrl = "http://gidonline.club/2016/03/strazhi-galaktiki/"
//
//    print(movieUrl)
//
//    let document = try subject.fetchDocument(movieUrl)
//
//    let serialInfo = try subject.getSerialInfo(document!)
//
//    print(JsonConverter.prettified(serialInfo))
//
//    for (key, value) in serialInfo["seasons"] {
//      print(key)
//      print(serial_info["seasons"][key])
//    }
  }

  func skip_testIsSerial() throws {
    let url = "http://gidonline.club/2016/07/priklyucheniya-vudi-i-ego-druzej/"

    let result = try subject.isSerial(url)

    print(JsonConverter.prettified(result))
  }

  func testSearch() throws {
    let query = "вуди"

    let result = try subject.search(query)

    print(JsonConverter.prettified(result))
  }

//  func testSearchActors() throws {
//    let query = "Аллен"
//
//    let result = try subject.searchActors(document, query)
//
//    print(JsonConverter.prettified(result))
//  }
//
//  func testSearchDirectors() throws {
//    let query = "Люк"
//
//    let result = try subject.searchDirectors(document, query)
//
//    print(JsonConverter.prettified(result))
//  }

}
