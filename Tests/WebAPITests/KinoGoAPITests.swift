import XCTest

@testable import WebAPI

class KinoGoAPITests: XCTestCase {
  var subject = KinoGoAPI()

  func testGetAvailable() throws {
    let result = try subject.available()

    XCTAssertEqual(result, true)
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
    print(try subject.getCategoriesByYear())
    print(try subject.getCategoriesByCountry())
    print(try subject.getCategoriesBySerie())

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

  func testGetUrls() throws {
    let path = "/11380-monstry-na-kanikulah-3_2018-25-09.html"

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
    let query = "красный"

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
    let path = "/3340-sladkaya-zhizn_1-2-3-sezon_20-09.html"

    let list = try subject.getSeasons(KinoGoAPI.SiteUrl + path)

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

}
