import XCTest

@testable import WebAPI

class GoogleDocsAPITests: XCTestCase {
  var subject = GoogleDocsAPI()

  func testGetMovies() throws {
    let result = try subject.getMovies()

    print(result as Any)
  }

  func testGetSeries() throws {
    let result = try subject.getSeries()

    print(result as Any)
  }

  func testGetLatest() throws {
    let result = try subject.getLatest()

    print(result as Any)
  }

  func testGetCategory() throws {
    let result = try subject.getCategory(category: "movies")

    print(result as Any)
  }

  func testGetGenres() throws {
    let result = try subject.getGenres()

    print(result as Any)
  }

  func testGetGenre() throws {
    let genres = try subject.getGenres()["movies"] as! [Any]

    let genre = genres[0] as! [String: Any]

    let path = genre["path"] as! String

    let result = try subject.getGenre(path: path)

    print(result as Any)
  }

  func testPaginationInMovies() throws {
    let result1 = try subject.getMovies(page: 1)

    let pagination1 = result1["pagination"] as! [String: Any]

    XCTAssertTrue(pagination1["has_next"] as! Bool)
    XCTAssertFalse(pagination1["has_previous"] as! Bool)
    XCTAssertEqual(pagination1["page"] as! Int, 1)

    let result2 = try subject.getMovies(page: 2)

    let pagination2 = result2["pagination"] as! [String: Any]

    print(pagination2)

    XCTAssertTrue(pagination2["has_next"] as! Bool)
    XCTAssertTrue(pagination2["has_previous"] as! Bool)
    XCTAssertEqual(pagination2["page"] as! Int, 2)
  }

  func testGetMovie() throws {
    let id = "/watch/the-bronze"

    let result = try subject.getMovie(id)

    print(result as Any)
  }

  func testGetEpisode() throws {
    let id = "/watch/the-grand-tour/s1/e2"

    let result = try subject.getMovie(id)

    print(result as Any)
  }
}
