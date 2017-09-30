import XCTest

@testable import WebAPI

class AudioKnigiAPITests: XCTestCase {
  var subject = AudioKnigiAPI()

  func testGetAuthorsLetters() throws {
    let result = try subject.getAuthorsLetters()

    //print(JsonConverter.prettified(result))

    XCTAssert(result.count > 0)
  }

  func testGetPerformersLetters() throws {
    let result = try subject.getPerformersLetters()

    //print(JsonConverter.prettified(result))

    XCTAssert(result.count > 0)
  }

  func testGetNewBooks() throws {
    let result = try subject.getNewBooks()

//    print(JsonConverter.prettified(result))

    XCTAssert(result.count > 0)
  }

  func testGetBestBooksByWeek() throws {
    let result = try subject.getBestBooks(period: "7")

//    print(JsonConverter.prettified(result))

    XCTAssert(result.count > 0)
  }

  func testGetBestBooksByMonth() throws {
    let result = try subject.getBestBooks(period: "30")

    // print(JsonConverter.prettified(result))

    XCTAssert(result.count > 0)
  }

  func testGetBestBooks() throws {
    let result = try subject.getBestBooks(period: "all")

    // print(JsonConverter.prettified(result))

    XCTAssert(result.count > 0)
  }

  func testGetAuthorBooks() throws {
    let result = try subject.getAuthors()
    let items = result["movies"] as! [Any]

    let id = (items[0] as! [String: String])["id"]!

    let books = try subject.getBooks(path: id)

    // print(JsonConverter.prettified(books))

    XCTAssert(books.count > 0)
  }

  func testGetPerformersBooks() throws {
    let result = try subject.getPerformers()
    let items = result["movies"] as! [Any]

    let id = (items[0] as! [String: String])["id"]!

    let books = try subject.getBooks(path: id)

    XCTAssert(books.count > 0)

    // print(JsonConverter.prettified(books))
  }

  func testGetAuthors() throws {
    let result = try subject.getAuthors()

    // print(JsonConverter.prettified(result))

    XCTAssert(result.count > 0)
  }

  func testGetPerformers() throws {
    let result = try subject.getPerformers()

    //print(JsonConverter.prettified(result))

    XCTAssert(result.count > 0)
  }

  func testGetGenres() throws {
    let result1 = try subject.getGenres(page: 1)

    //print(JsonConverter.prettified(result1))

    XCTAssert(result1.count > 0)

    let result2 = try subject.getGenres(page: 2)

    // print(JsonConverter.prettified(result2))

    XCTAssert(result2.count > 0)
  }

  func testGetGenre() throws {
    let genres = try subject.getGenres(page: 1)

    let items = genres["movies"] as! [Any]

    let id = (items[0] as! [String: String])["id"]!

    let result = try subject.getGenre(path: id)

    //print(JsonConverter.prettified(result))

    XCTAssert(result.count > 0)
  }

  func testPagination() throws {
    let result1 = try subject.getNewBooks(page: 1)

    let pagination1 = result1["pagination"] as! [String: Any]

    XCTAssertEqual(pagination1["has_next"] as! Bool, true)
    XCTAssertEqual(pagination1["has_previous"] as! Bool, false)
    XCTAssertEqual(pagination1["page"] as! Int, 1)

    let result2 = try subject.getNewBooks(page: 2)

    let pagination2 = result2["pagination"] as! [String: Any]

    XCTAssertEqual(pagination2["has_next"] as! Bool, true)
    XCTAssertEqual(pagination2["has_previous"] as! Bool, true)
    XCTAssertEqual(pagination2["page"] as! Int, 2)
  }

  func testGetAudioTracks() throws {
    let path = "http://audioknigi.club/alekseev-gleb-povesti-i-rasskazy"

    let result = try subject.getAudioTracks(path)

    //print(result)

    XCTAssert(result.count > 0)
  }

//  func testDownloadAudioTracks() throws {
//    let path = "http://audioknigi.club/alekseev-gleb-povesti-i-rasskazy"
//
//    let result = try subject.downloadAudioTracks(path)
//
////    print(result)
//  }

  func testSearch() throws {
    let query = "пратчетт"

    let result = try subject.search(query)

    //print(JsonConverter.prettified(result))

    XCTAssert(result.count > 0)
  }

  func testGrouping() throws {
    let data: Data? = Files.readFile("authors.json")

    let items: [NameClassifier.Item] = try JSONDecoder().decode([NameClassifier.Item].self, from: data!)

    let classifier = NameClassifier()
    let classified = try classifier.classify(items: items)

    //print(classified)

    XCTAssert(classified.count > 0)
  }

  func testGenerateAuthorsList() throws {
    try generateAuthorsList("authors.json")
  }

  func _testGeneratePerformersList() throws {
    try generatePerformersList("performers.json")
  }

  func _testGenerateAuthorsInGroupsList() throws {
    let data: Data? = Files.readFile("authors.json")

    let items: [NameClassifier.Item] = try JSONDecoder().decode([NameClassifier.Item].self, from: data!)

    let classifier = NameClassifier()
    let classified = try classifier.classify2(items: items)

    let encoder = JSONEncoder()
    let data2 = try encoder.encode(classified)

    print(JsonConverter.prettified(data2))

    _ = Files.createFile("authors-in-groups.json", data: data2)
  }

  func _testGeneratePerformersInGroupsList() throws {
    let data: Data? = Files.readFile("performers.json")

    let items: [NameClassifier.Item] = try JSONDecoder().decode([NameClassifier.Item].self, from: data!)

    let classifier = NameClassifier()
    let classified = try classifier.classify2(items: items)

    let encoder = JSONEncoder()
    let data2 = try encoder.encode(classified)

    print(JsonConverter.prettified(data2))

    _ = Files.createFile("performers-in-groups.json", data: data2)
  }

  private func generateAuthorsList(_ fileName: String) throws {
    var list = [Any]()

    var result = try subject.getAuthors()

    list += (result["movies"] as! [Any])

    let pagination = result["pagination"] as! [String: Any]

    let pages = pagination["pages"] as! Int

    for page in (2...pages) {
      result = try subject.getAuthors(page: page)

      list += (result["movies"] as! [Any])
    }

    let filteredList = list.map {["id": ($0 as! [String: String])["id"]!, "name": ($0 as! [String: String])["name"]!] }

    _ = Files.createFile(fileName, data: try Prettifier.asPrettifiedData(filteredList))
  }

  private func generatePerformersList(_ fileName: String) throws {
    var list = [Any]()

    var result = try subject.getPerformers()

    list += (result["movies"] as! [Any])

    let pagination = result["pagination"] as! [String: Any]

    let pages = pagination["pages"] as! Int

    for page in (2...pages) {
      result = try subject.getPerformers(page: page)

      list += (result["movies"] as! [Any])
    }

    let filteredList = list.map {["id": ($0 as! [String: String])["id"]!, "name": ($0 as! [String: String])["name"]!] }

    _ = Files.createFile(fileName, data: try Prettifier.asPrettifiedData(filteredList))
  }
}
