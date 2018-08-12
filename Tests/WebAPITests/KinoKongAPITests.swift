import XCTest

@testable import WebAPI

class KinoKongAPITests: XCTestCase {
  var subject = KinoKongAPI()

  func testGetAvailable() throws {
    let result = try subject.available()

    XCTAssertEqual(result, true)
  }

  func testGetAllMovies() throws {
    let list = try subject.getAllMovies()

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetNewMovies() throws {
    let list = try subject.getNewMovies()

    // print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetAllSeries() throws {
    let list = try subject.getAllSeries()

    //print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetGroupedGenres() throws {
    let list = try subject.getGroupedGenres()

    print(try list.prettify())

//
//    XCTAssertNotNil(list)
//    XCTAssert(list.count > 0)
  }

  func testGetUrls() throws {
    let path = "/32334-chernaya-pantera-2018-online.html"

    let list = try subject.getUrls(KinoKongAPI.SiteUrl + path)

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetSeriePlaylistUrl() throws {
    let path = "/25213-rodoslovnaya-03-06-2016.html"

    let list = try subject.getSeriePlaylistUrl(path)

    //print(result as Any)

    print(list)
  }

  func testGetMetadata() throws {
    let path = "/26545-lovushka-dlya-privideniya-2015-smotret-online.html"

    let urls = try subject.getUrls(path)

    let list = subject.getMetadata(urls[0])

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testSearch() throws {
    let query = "красный"

    let list = try subject.search(query)

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

//    let pagination2 = result2["pagination"] as! [String: Any]
//
//    //print(pagination2)
//
//    XCTAssertTrue(pagination2["has_next"] as! Bool)
//    XCTAssertTrue(pagination2["has_previous"] as! Bool)
//    XCTAssertEqual(pagination2["page"] as! Int, 2)
  }

  func testPaginationInMoviesByRating() throws {
    let result1 = try subject.getMoviesByRating(page: 1)

    let pagination1 = result1["pagination"] as! [String: Any]

    //print(pagination1)

    XCTAssertFalse(pagination1["has_next"] as! Bool)
    XCTAssertFalse(pagination1["has_previous"] as! Bool)
    XCTAssertEqual(pagination1["page"] as! Int, 1)
  }

  func testGetMultipleSeasons() throws {
    let path = "/28206-v-obezd-2015-07-06-2016.html"

    let playlistUrl = try subject.getSeriePlaylistUrl(path)

    let list = try subject.getSeasons(playlistUrl, path: "")

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetSingleSeason() throws {
    let path = "/31759-orvill-06-10-2017.html"

    let playlistUrl = try subject.getSeriePlaylistUrl(path)

    let list = try subject.getSeasons(playlistUrl, path: "")

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetMoviesByRating() throws {
    let list = try subject.getMoviesByRating()

    print(try list.prettify())

//    XCTAssertNotNil(list)
//    XCTAssert(list.count > 0)
  }

  func testGetTags() throws {
    let list = try subject.getTags()

    print(try list.prettify())

//    XCTAssertNotNil(list)
//    XCTAssert(list.count > 0)
  }

  func testGetSoundtracks() throws {
    let path = "/15479-smotret-dedpul-2016-smotet-online.html"

    let playlistUrl = try subject.getSeriePlaylistUrl(path)
    let list = try subject.getSeasons(playlistUrl, path: "")

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }
}
