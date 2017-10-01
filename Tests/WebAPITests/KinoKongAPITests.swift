import XCTest
import SwiftyJSON

@testable import WebAPI

class KinoKongAPITests: XCTestCase {
  var subject = KinoKongAPI()

  func testGetAvailable() throws {
    let result = try subject.available()

    XCTAssertEqual(result, true)
  }

  func testGetAllMovies() throws {
    let result = try subject.getAllMovies()

    print(JsonConverter.prettified(result))
  }

  func testGetNewMovies() throws {
    let result = try subject.getNewMovies()

    print(JsonConverter.prettified(result))
  }

  func testGetAllSeries() throws {
    let result = try subject.getAllSeries()

    print(JsonConverter.prettified(result))
  }

  func testGetSeasons() throws {
    let path = "/22422-morskaya-policiya-novyy-orlean-1-3-sezon-26-04-2017.html"
    let result = try subject.getSeasons(path, serieName: "serieName", thumb: "thumb")

    print(JsonConverter.prettified(result))
  }

  func testGetGroupedGenres() throws {
    let result = try subject.getGroupedGenres()

    print(JsonConverter.prettified(result))
  }

  func testGetUrls() throws {
    let path = "/26545-lovushka-dlya-privideniya-2015-smotret-online.html"

    let result = try subject.getUrls(path)

    print(JsonConverter.prettified(result))
  }

  func testGetSeriePlaylistUrl() throws {
    let path = "/25213-rodoslovnaya-03-06-2016.html"

    let result = try subject.getSeriePlaylistUrl(path)

    print(JsonConverter.prettified(result))
  }

  func testGetMetadata() throws {
    let path = "/26545-lovushka-dlya-privideniya-2015-smotret-online.html"

    let urls = try subject.getUrls(path)

    let result = subject.getMetadata(urls[0])

    print(JsonConverter.prettified(result))
  }

  func testSearch() throws {
    let query = "красный"

    let result = try subject.search(query)

    print(JsonConverter.prettified(result))
  }

  func testPaginationInAllMovies() throws {
    let result1 = try subject.getAllMovies(page: 1)

    let pagination1 = result1["pagination"] as! [String: Any]

    //print(pagination1)

    XCTAssertTrue(pagination1["has_next"] as! Bool)
    XCTAssertFalse(pagination1["has_previous"] as! Bool)
    XCTAssertEqual(pagination1["page"] as! Int, 1)

    let result2 = try subject.getAllMovies(page: 2)

    let pagination2 = result2["pagination"] as! [String: Any]

    //print(pagination2)

    XCTAssertTrue(pagination2["has_next"] as! Bool)
    XCTAssertTrue(pagination2["has_previous"] as! Bool)
    XCTAssertEqual(pagination2["page"] as! Int, 2)
  }

  func testPaginationInMoviesByRating() throws {
    let result1 = try subject.getMoviesByRating(page: 1)

    let pagination1 = result1["pagination"] as! [String: Any]

    //print(pagination1)

    XCTAssertFalse(pagination1["has_next"] as! Bool)
    XCTAssertFalse(pagination1["has_previous"] as! Bool)
    XCTAssertEqual(pagination1["page"] as! Int, 1)
  }

  func testGeMultipleSeasonsSerieInfo() throws {
    let path = "/28206-v-obezd-2015-07-06-2016.html"

    let playlistUrl = try subject.getSeriePlaylistUrl(path)

    let list = try subject.getSerieInfo(playlistUrl)

    print(try Prettifier.prettify { encoder in
      return try encoder.encode(list)
    })

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetSingleSeasonSerieInfo() throws {
    let path = "/31759-orvill-06-10-2017.html"

    let playlistUrl = try subject.getSeriePlaylistUrl(path)

    let list = try subject.getSerieInfo(playlistUrl)

    print(try Prettifier.prettify { encoder in
      return try encoder.encode(list)
    })

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetMoviesByRating() throws {
    let result = try subject.getMoviesByRating()

    print(JsonConverter.prettified(result))
  }

  func testGetTags() throws {
    let result = try subject.getTags()

    print(JsonConverter.prettified(result))
  }

  func testGetSoundtracks() throws {
    let path = "/15479-smotret-dedpul-2016-smotet-online.html"

    let playlistUrl = try subject.getSeriePlaylistUrl(path)
    let result = try subject.getSerieInfo(playlistUrl)

    print(JsonConverter.prettified(JSON(result)))
  }
}
