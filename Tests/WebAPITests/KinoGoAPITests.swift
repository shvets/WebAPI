import XCTest

@testable import WebAPI

class KinoGoAPITests: XCTestCase {
  var subject = KinoGoAPI()

  func testGetAvailable() throws {
    let result = try subject.available()

    XCTAssertEqual(result, true)
  }

  func testGetCookie() throws {
    if let result = subject.getCookie(url: "https://kinogo.by/11361-venom_2018_08-10.html") {
      print(result)

      XCTAssertNotNil(result)
    } else {
      XCTFail("Empty result")
    }
  }

  func testGetAllCategories() throws {
    let list = try subject.getAllCategories()

    print(list["Категории"]!)
    print(list["По году"]!)
    print(list["По странам"]!)
    print(list["Сериалы"]!)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetCategoriesByGroup() throws {
    print(try subject.getCategoriesByTheme())
//    print(try subject.getCategoriesByYear())
//    print(try subject.getCategoriesByCountry())
//    print(try subject.getCategoriesBySerie())

//    XCTAssertNotNil(list)
//    XCTAssert(list.count > 0)
  }

  func testGetAllMovies() throws {
    let list = try subject.getAllMovies()

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetPremierMovies() throws {
    let list = try subject.getPremierMovies()

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetLastMovies() throws {
    let list = try subject.getLastMovies()

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetAllSeries() throws {
    let list = try subject.getAllSeries()

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetAnimations() throws {
    let list = try subject.getAnimations()

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetAnime() throws {
    let list = try subject.getAnime()

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetTvShows() throws {
    let list = try subject.getTvShows()

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetMoviesByCountry() throws {
    print("Франция".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
    let list = try subject.getMoviesByCountry(country: "/tags/Франция/")
//https://kinogo.by/tags/%D0%A4%D1%80%D0%B0%D0%BD%D1%86%D0%B8%D1%8F/
    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetMoviesByYear() throws {
    let list = try subject.getMoviesByYear(year: 2008)

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetUrls() throws {
    let path = "/11410-velikiy-uravnitel-2_2018____04-11.html"

    let list = try subject.getUrls(KinoGoAPI.SiteUrl + path)

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

//  func testGetSeriePlaylistUrl() throws {
//    let path = "/8892-legion-2-sezon-2018-11.html"
//
//    let list = try subject.getSeasonPlaylistUrl(path)
//
//    // print(list)
//
//    XCTAssertNotNil(list)
//    XCTAssert(list.count > 0)
//  }

  func testSearch() throws {
    let query = "мердок"

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
    let path = "/14452-fitnes-1-sezon_2018_17-10.html"

    let list = try subject.getSeasons(KinoGoAPI.SiteUrl + path)

    print(list)
//    print(list.first!.playlist.first!.comment)
//    print(list.first!.playlist.first!.name)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

}
