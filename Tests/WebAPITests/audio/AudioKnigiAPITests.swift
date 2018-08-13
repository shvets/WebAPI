import XCTest
import Files

@testable import WebAPI

class AudioKnigiAPITests: XCTestCase {
  var subject = AudioKnigiAPI()

//  func testGetAuthorsLetters() throws {
//    let result = try subject.getAuthorsLetters()
//
//    print(result as Any)
//
//    XCTAssert(result.count > 0)
//  }

  func testGetAuthorsLetters() throws {
    let exp = expectation(description: "Gets authors letters")

    _ = subject.getAuthorsLetters().subscribe(onNext: { result in
      print(result as Any)

      XCTAssert(result.count > 0)

      exp.fulfill()
    },
    onError: { error in
      print("Received error:", error)
    })

    waitForExpectations(timeout: 10, handler: nil)
  }

//  func testGetPerformersLetters() throws {
//    let result = try subject.getPerformersLetters()
//
//    //print(result as Any)
//
//    XCTAssert(result.count > 0)
//  }

  func testGetNewBooks() throws {
    let exp = expectation(description: "Gets new books")

    _ = subject.getNewBooks().subscribe(onNext: { result in
      print(result as Any)

      XCTAssert(result.count > 0)

      exp.fulfill()
    })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetBestBooksByWeek() throws {
    let exp = expectation(description: "Gets best books by week")

    _ = subject.getBestBooks(period: "7").subscribe(onNext: { result in
      //print(result as Any)

      XCTAssert(result.count > 0)

      exp.fulfill()
    })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetBestBooksByMonth() throws {
    let exp = expectation(description: "Gets best books by month")

    _ = subject.getBestBooks(period: "30").subscribe(onNext: { result in
      //print(result as Any)

      XCTAssert(result.count > 0)

      exp.fulfill()
    })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetBestBooks() throws {
    let exp = expectation(description: "Gets best books")

    _ = subject.getBestBooks(period: "all").subscribe(onNext: { result in
      //print(result as Any)

      XCTAssert(result.count > 0)

      exp.fulfill()
    })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetAuthorBooks() throws {
    let exp = expectation(description: "Gets author books")

    _ = subject.getAuthors().subscribe(onNext: { result in
      let items = result["movies"] as! [Any]

      let id = (items[0] as! [String: String])["id"]!

      _ = self.subject.getBooks(path: id).subscribe(onNext: { books in
        // print(books)

        XCTAssert(books.count > 0)
      })

      exp.fulfill()
    })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetPerformersBooks() throws {
    let exp = expectation(description: "Gets performers books")

    _ = subject.getPerformers().subscribe(onNext: { result in
      let items = result["movies"] as! [Any]

      let id = (items[0] as! [String: String])["id"]!

      _ = self.subject.getBooks(path: id).subscribe(onNext: { books in
        XCTAssert(books.count > 0)

        // print(books)
      })

      exp.fulfill()
    })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetAuthors() throws {
    let exp = expectation(description: "Gets authors")

    _ = subject.getAuthors().subscribe(onNext: { result in
      // print(result as Any)

      XCTAssert(result.count > 0)

      exp.fulfill()
    })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetPerformers() throws {
    let exp = expectation(description: "Gets performers")

    _ = subject.getPerformers().subscribe(onNext: { result in
      // print(result as Any)

      XCTAssert(result.count > 0)

      exp.fulfill()
    })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetAllGenres() throws {
    let exp = expectation(description: "Gets all genres")

    _ = subject.getGenres(page: 1).subscribe(onNext: { result in
      print(result)

      XCTAssert(result.count > 0)

      exp.fulfill()
    })

    _ = subject.getGenres(page: 2).subscribe(onNext: { result in
      print(result)

      XCTAssert(result.count > 0)

      exp.fulfill()
    })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetGenre() throws {
    let exp = expectation(description: "Gets all genres")

    _ = subject.getGenres(page: 1).subscribe(onNext: { result in
      let items = result["movies"] as! [Any]

      let id = (items[0] as! [String: Any])["id"] as? String

      //print(items[0] as? [String: Any])

      _ = self.subject.getGenre(path: id!).subscribe(onNext: { result in
        //print(result as Any)

        XCTAssert(result.count > 0)

        exp.fulfill()
      })

      exp.fulfill()
    })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testPagination() throws {
    let exp = expectation(description: "Gets pagination")

    _ = subject.getNewBooks(page: 1).subscribe(onNext: { result in
      let pagination1 = result["pagination"] as! [String: Any]

      XCTAssertEqual(pagination1["has_next"] as! Bool, true)
      XCTAssertEqual(pagination1["has_previous"] as! Bool, false)
      XCTAssertEqual(pagination1["page"] as! Int, 1)

      exp.fulfill()
    })

    _ = subject.getNewBooks(page: 2).subscribe(onNext: { result in
      let pagination2 = result["pagination"] as! [String: Any]

      XCTAssertEqual(pagination2["has_next"] as! Bool, true)
      XCTAssertEqual(pagination2["has_previous"] as! Bool, true)
      XCTAssertEqual(pagination2["page"] as! Int, 2)

      exp.fulfill()
    })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetAudioTracks() throws {
    let path = "http://audioknigi.club/alekseev-gleb-povesti-i-rasskazy"

    let exp = expectation(description: "Gets audio tracks")

    _ = subject.getAudioTracks(path).subscribe(onNext: { result in
      do {
        print(try result.prettify())
      }
      catch {

      }

      XCTAssertNotNil(result)
      XCTAssert(result.count > 0)

      exp.fulfill()
    })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testSearch() throws {
    let query = "пратчетт"

    let exp = expectation(description: "Search")

    _ = subject.search(query).subscribe(onNext: { result in
      //print(result as Any)

      XCTAssert(result.count > 0)

      exp.fulfill()
    })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGrouping() throws {
    let data: Data? = try File(path: "authors.json").read()

    let items: [NameClassifier.Item] = try data!.decoded() as [NameClassifier.Item]

    let classifier = NameClassifier()
    let classified = try classifier.classify(items: items)

    //print(classified)

    XCTAssert(classified.count > 0)
  }

  func testGenerateAuthorsList() throws {
    try generateAuthorsList("authors.json")
  }

  func testGeneratePerformersList() throws {
    try generatePerformersList("performers.json")
  }

  func testGenerateAuthorsInGroupsList() throws {
    let data: Data? = try File(path: "authors.json").read()

    let items: [NameClassifier.Item] = try data!.decoded() as [NameClassifier.Item]

    let classifier = NameClassifier()
    let classified = try classifier.classify2(items: items)

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data2 = try encoder.encode(classified)

    //print(data2)

    try FileSystem().createFile(at: "authors-in-groups.json", contents: data2)
  }

  func testGeneratePerformersInGroupsList() throws {
    let data: Data? = try File(path: "performers.json").read()

    let items: [NameClassifier.Item] = try data!.decoded() as [NameClassifier.Item]

    let classifier = NameClassifier()
    let classified = try classifier.classify2(items: items)

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data2 = try encoder.encode(classified)

    //print(data2)

    try FileSystem().createFile(at: "performers-in-groups.json", contents: data2)
  }

  private func generateAuthorsList(_ fileName: String) throws {
    var list = [Any]()

    let semaphore1 = DispatchSemaphore.init(value: 0)

    _ = subject.getAuthors().subscribe(onNext: { result in
      list += (result["movies"] as! [Any])

      let pagination = result["pagination"] as! [String: Any]

      let semaphore2 = DispatchSemaphore.init(value: 0)

      let pages = pagination["pages"] as! Int

      for page in (2...pages) {
        _ = self.subject.getAuthors(page: page).subscribe(onNext: { result in
          list += (result["movies"] as! [Any])

          semaphore2.signal()
        })

        _ = semaphore2.wait(timeout: DispatchTime.distantFuture)
      }

      semaphore1.signal()
    })

    _ = semaphore1.wait(timeout: DispatchTime.distantFuture)

    let filteredList = list.map {["id": ($0 as! [String: String])["id"]!, "name": ($0 as! [String: String])["name"]!] }

    try FileSystem().createFile(at: fileName, contents: try asPrettifiedData(filteredList))
  }

  private func generatePerformersList(_ fileName: String) throws {
    var list = [Any]()

    let semaphore1 = DispatchSemaphore.init(value: 0)

    _ = subject.getPerformers().subscribe(onNext: { result in
      list += (result["movies"] as! [Any])

      let pagination = result["pagination"] as! [String: Any]

      let semaphore2 = DispatchSemaphore.init(value: 0)

      let pages = pagination["pages"] as! Int

      for page in (2...pages) {
        _ = self.subject.getPerformers(page: page).subscribe(onNext: { result in
          list += (result["movies"] as! [Any])

          semaphore2.signal()
        })

        _ = semaphore2.wait(timeout: DispatchTime.distantFuture)
      }

      semaphore1.signal()
    })

    _ = semaphore1.wait(timeout: DispatchTime.distantFuture)

    let filteredList = list.map {["id": ($0 as! [String: String])["id"]!, "name": ($0 as! [String: String])["name"]!] }

    try FileSystem().createFile(at: fileName, contents: try asPrettifiedData(filteredList))
  }

  var encoder: JSONEncoder = {
    let encoder = JSONEncoder()

    encoder.outputFormatting = .prettyPrinted

    return encoder
  }()

  public func asPrettifiedData(_ value: Any) throws -> Data {
    if let value = value as? [[String: String]] {
      return try encoder.encode(value)
    }
    else if let value = value as? [String: String] {
      return try encoder.encode(value)
    }

    return Data()
  }
}
