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
      document = try subject.fetchDocument(GidOnlineAPI.SITE_URL)
    }
    catch {
      print("Error fetching document")
    }
  }

//  override func tearDown() {
//    super.tearDown()
//  }

  func testGetGenres() throws {
    let result = try subject.getGenres(document!)

    print(JsonConverter.prettified(result))
  }

  func testGetTopLinks() throws {
    let result = try subject.getTopLinks(document!)

    print(JsonConverter.prettified(result))
  }

  func testGetActors() throws {
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
    let document = try subject.fetchDocument(GidOnlineAPI.SITE_URL + "/genre/vestern/")

    let result = try subject.getMovies(document!, path: "/genre/vestern/")

    print(JsonConverter.prettified(result))
  }

  func testGetMovieUrl() throws {
    let movieUrl = "http://gidonline.club/2017/01/ulichnyj-kot-po-klichke-bob/"

    let urls = try subject.getUrls(movieUrl)

    print(JsonConverter.prettified(urls))
  }

  func testGetSerialInfo() throws {
    let url = "http://gidonline.club/2016/03/strazhi-galaktiki/"

    let result = try subject.getSerialInfo(url)

    print(JsonConverter.prettified(result))
  }

  func testGetMediaData() throws {
    let allMovies = try subject.getAllMovies()["movies"]! as! [Any]

    let movieUrl = (allMovies[0] as! [String: String])["id"]!

    let document = try subject.fetchDocument(movieUrl)

    let result = try subject.getMediaData(document!)

    print(JsonConverter.prettified(result))
  }

  func skip_testIsSerial() throws {
    let url = "http://gidonline.club/2016/07/priklyucheniya-vudi-i-ego-druzej/"

    let result = try subject.isSerial(url)

    print(JsonConverter.prettified(result))
  }

  func testSearch() throws {
    let query = "акула"

    let result = try subject.search(query)

    print(JsonConverter.prettified(result))
  }

  func testSearchActors() throws {
    let query = "Аллен"

    let result = try subject.searchActors(document!, query: query)

    print(JsonConverter.prettified(result))
  }

  func testSearchDirectors() throws {
    let query = "Люк"

    let result = try subject.searchDirectors(document!, query: query)

    print(JsonConverter.prettified(result))
  }

  func testSearchCountries() throws {
    let query = "Франция"

    let result = try subject.searchCountries(document!, query: query)

    print(JsonConverter.prettified(result))
  }

  func testSearchYears() throws {
    let query = "1984"

    let result = try subject.searchYears(document!, query: query)

    print(JsonConverter.prettified(result))
  }

}