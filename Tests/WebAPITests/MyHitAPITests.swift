import XCTest
import SwiftyJSON

@testable import WebAPI

class MyHitAPITests: XCTestCase {
  var subject = MyHitAPI()

  func testAvailable() throws {
    let result = try subject.available()

    print(try result.text())
  }

  func testGetAllMovies() throws {
    let result = try subject.getAllMovies()

    print(JsonConverter.prettified(result))
  }

  func testGetAllSeries() throws {
    let result = try subject.getAllSeries()

    print(JsonConverter.prettified(result))
  }

  func testGetPopularMovies() throws {
    let result = try subject.getPopularMovies()

    print(JsonConverter.prettified(result))
  }

  func testGetPopularSeries() throws {
    let result = try subject.getPopularSeries()

    print(JsonConverter.prettified(result))
  }

  func testGetSoundtracks() throws {
    let result = try subject.getSoundtracks()

    print(JsonConverter.prettified(result))
  }

  func testGetAlbums() throws {
    let soundtracks = try subject.getSoundtracks()["movies"]!

    let soundtrack = (soundtracks as! [Any])[0]

    let path = (soundtrack as! [String: String])["id"]!

    let result = try subject.getAlbums(path)

    print(JsonConverter.prettified(result))
  }

  func testGetSelections() throws {
    let result = try subject.getSelections()

    print(JsonConverter.prettified(result))
  }

  func testGetSelection() throws {
    let selections = try subject.getSelections()["movies"]!

    let selection = (selections as! [Any])[0]

    let path = (selection as! [String: Any])["id"]!

    let result = try subject.getSelection(path: path as! String)

    print(JsonConverter.prettified(result))
  }

  func testGetSeasons() throws {
    let result = subject.getSeasons("\(GidOnlineAPI.SiteUrl)/2016/03/strazhi-galaktiki/", parentName: "parentName")

    print(JsonConverter.prettified(result))
  }

  func testPaginationInPopularMovies() throws {
    let result1 = try subject.getPopularMovies(page: 1)

    let pagination1 = result1["pagination"] as! [String: Any]

    XCTAssertTrue(pagination1["has_next"] as! Bool)
    XCTAssertFalse(pagination1["has_previous"] as! Bool)
    XCTAssertEqual(pagination1["page"] as! Int, 1)

    let result2 = try subject.getPopularMovies(page: 2)

    let pagination2 = result2["pagination"] as! [String: Any]

    print(pagination2)

    XCTAssertTrue(pagination2["has_next"] as! Bool)
    XCTAssertTrue(pagination2["has_previous"] as! Bool)
    XCTAssertEqual(pagination2["page"] as! Int, 2)
  }

  func testSearch() throws {
    let query = "ред"

    let result = try subject.search(query)

    print(JsonConverter.prettified(result))

    let pagination = result["pagination"] as! [String: Any]

    XCTAssertEqual(pagination.keys.count, 4)
  }

  func testGetSerie() throws {
    let series = try subject.getAllSeries()["movies"] as! [Any]

    let serie = series[0] as! [String: Any]
    let path = serie["id"] as! String

    let result = subject.getSeasons(path)

    print(JsonConverter.prettified(result))
  }

  func testGetUrls() throws {
    let path = "/film/414864/"

    let result = try subject.getUrls(path: path)

    print(JsonConverter.prettified(JSON(result)))
  }

  func testGetMetadata() throws {
    let path = "/film/414864/"

    let urls = try subject.getUrls(path: path)

    print(JsonConverter.prettified(JSON(urls)))

    let url = urls[0]

    let metadata = try subject.getMetadata(url)

    print(JsonConverter.prettified(JSON(metadata)))
  }

  func testGetMediaData() throws {
    //let path = "/film/414864/"
    let path = "/serial/1933/"

    let result = try subject.getMediaData(pathOrUrl: path)

    print(JsonConverter.prettified(JSON(result)))
  }

  func testGetFilmFilters() throws {
    let result = try subject.getFilters(mode: "film")

    print(JsonConverter.prettified(JSON(result)))
  }

  func testGetSerieFilters() throws {
    let result = try subject.getFilters(mode: "serial")

    print(JsonConverter.prettified(JSON(result)))
  }

}
