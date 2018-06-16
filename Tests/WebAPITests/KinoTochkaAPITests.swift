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

    // print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetAnimations() throws {
    let list = try subject.getAnimations()

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

//  func testGetGroupedGenres() throws {
//    let list = try subject.getGroupedGenres()
//
//    print(list)
//
//    //    print(try Prettifier.prettify { encoder in
////      return try encoder.encode(list)
////    })
////
////    XCTAssertNotNil(list)
////    XCTAssert(list.count > 0)
//  }

  func testGetUrls() throws {
    let path = "/5271-lara-kroft-3-2018.html"

    let list = try subject.getUrls(KinoTochkaAPI.SiteUrl + path)

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetSeriePlaylistUrl() throws {
    let path = "/8892-legion-2-sezon-2018-11.html"

    let list = try subject.getSeriePlaylistUrl(path)

    // print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

//  func testGetMetadata() throws {
//    let path = "/26545-lovushka-dlya-privideniya-2015-smotret-online.html"
//
//    let urls = try subject.getUrls(path)
//
//    let list = subject.getMetadata(urls[0])
//
//    //print(result as Any)
//
//    //print(list)
//
//    //    print(try Prettifier.prettify { encoder in
////      return try encoder.encode(list)
////    })
//
//    XCTAssertNotNil(list)
//    XCTAssert(list.count > 0)
//  }

  func testSearch() throws {
    let query = "красный"

    let list = try subject.search(query)

    // print(list)

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

    //print(pagination2)

    XCTAssertTrue(pagination2["has_next"] as! Bool)
    XCTAssertTrue(pagination2["has_previous"] as! Bool)
    XCTAssertEqual(pagination2["page"] as! Int, 2)
  }

//  func testPaginationInMoviesByRating() throws {
//    let result1 = try subject.getMoviesByRating(page: 1)
//
//    let pagination1 = result1["pagination"] as! [String: Any]
//
//    //print(pagination1)
//
//    XCTAssertFalse(pagination1["has_next"] as! Bool)
//    XCTAssertFalse(pagination1["has_previous"] as! Bool)
//    XCTAssertEqual(pagination1["page"] as! Int, 1)
//  }

  func testGetSeasonMovies() throws {
    let path = "/9146-chastnye-syschiki-2-sezon-2017-12.html"

    let playlistUrl = try subject.getSeriePlaylistUrl(path)

    let list = try subject.getSeasons(playlistUrl, path: "")

    print(try Prettifier.prettify { encoder in
      return try encoder.encode(list)
    })

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetSeasonsList() throws {
    let path = "/9146-chastnye-syschiki-2-sezon-2017-12.html"

    let list = try subject.getSeasonsList(path)

     // print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetCollections() throws {
    let list = try subject.getCollections()

    // print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetCollection() throws {
    let path = "/podborki/new_year/"

    let list = try subject.getCollection(path)

    // print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

//  func testGetMoviesByRating() throws {
//    let list = try subject.getMoviesByRating()
//
//    //print(result as Any)
//
//    print(list)
//
//    //    print(try Prettifier.prettify { encoder in
////      return try encoder.encode(list)
////    })
////
////    XCTAssertNotNil(list)
////    XCTAssert(list.count > 0)
//  }
//
//  func testGetTags() throws {
//    let list = try subject.getTags()
//
//    //print(result as Any)
//
//    print(list)
//
//    //    print(try Prettifier.prettify { encoder in
////      return try encoder.encode(list)
////    })
////
////    XCTAssertNotNil(list)
////    XCTAssert(list.count > 0)
//  }
//
//  func testGetSoundtracks() throws {
//    let path = "/15479-smotret-dedpul-2016-smotet-online.html"
//
//    let playlistUrl = try subject.getSeriePlaylistUrl(path)
//    let list = try subject.getSeasons(playlistUrl, path: "")
//
//    print(try Prettifier.prettify { encoder in
//      return try encoder.encode(list)
//    })
//
//    XCTAssertNotNil(list)
//    XCTAssert(list.count > 0)
//  }
}
