import XCTest

@testable import WebAPI

class KinoTochkaAPITests: XCTestCase {
  var subject = KinoTochkaAPI()

  func testGetAvailable() throws {
    let result = try subject.available()

    XCTAssertEqual(result, true)
  }

  func testGetAllMovies() throws {
    let list = try subject.getAllMovies()

    // print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetNewMovies() throws {
    let list = try subject.getNewMovies()

    // print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetAllSeries() throws {
    let list = try subject.getAllSeries()

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetRussianAnimations() throws {
    let list = try subject.getRussianAnimations()

    // print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetForeignAnimations() throws {
    let list = try subject.getForeignAnimations()

    // print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetAnime() throws {
    let list = try subject.getAnime()

    // print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetTvShows() throws {
    let list = try subject.getTvShows()

    // print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }
  
  func testGetUrls() throws {
    let path = "/10474-uteya-22-iyulya-2018.html"

    let list = try subject.getUrls(KinoTochkaAPI.SiteUrl + path)

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetSeriePlaylistUrl() throws {
    let path = "/8892-legion-2-sezon-2018-11.html"

    let list = try subject.getSeasonPlaylistUrl(KinoTochkaAPI.SiteUrl + path)

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testSearch() throws {
    let query = "ивановы"

    let list = try subject.search(query)

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testPaginationInAllMovies() throws {
    let result1 = try subject.getAllMovies(page: 1)

    let pagination1 = result1["pagination"] as! [String: Any]

    print(pagination1)

    XCTAssertTrue(pagination1["has_next"] as! Bool)
    XCTAssertFalse(pagination1["has_previous"] as! Bool)
    XCTAssertEqual(pagination1["page"] as! Int, 1)

    let result2 = try subject.getAllMovies(page: 2)
    print(result2)

    let pagination2 = result2["pagination"] as! [String: Any]

    XCTAssertTrue(pagination2["has_next"] as! Bool)
    XCTAssertTrue(pagination2["has_previous"] as! Bool)
    XCTAssertEqual(pagination2["page"] as! Int, 2)
  }

  func testGetSeasons() throws {
    let path = "/6914-byvaet-i-huzhe-2-sezon-2010.html"

    let list = try subject.getSeasons(KinoTochkaAPI.SiteUrl + path)

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetEpisodes() throws {
    let path = "/11992-milliardy-4-sezon-2019-5.html"

    let playlistUrl = try subject.getSeasonPlaylistUrl(KinoTochkaAPI.SiteUrl + path)

    let list = try subject.getEpisodes(playlistUrl, path: "")

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }
  
  func testGetAllCollections() throws {
    let list = try subject.getCollections()

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetCollection() throws {
    let path = "/podborki/bestfilms2017/"

    let list = try subject.getCollection(path)

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetAllUserCollections() throws {
    let list = try subject.getUserCollections()

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetUserCollection() throws {
    let path = "/playlist/897/"

    let list = try subject.getUserCollection(path)

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

}
