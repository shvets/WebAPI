import XCTest
import SwiftyJSON

@testable import WebAPI

class AudioKnigiAPITests: XCTestCase {
  var subject = AudioKnigiAPI()

  func testGetAuthorsLetters() throws {
    let result = try subject.getAuthorsLetters()

    print(JsonConverter.prettified(result))
  }

  func testGetPerformersLetters() throws {
    let result = try subject.getPerformersLetters()

    print(JsonConverter.prettified(result))
  }

  func testGetNewBooks() throws {
    let result = try subject.getNewBooks()

    print(JsonConverter.prettified(result))
  }

  func testGetBestBooksByWeek() throws {
    let result = try subject.getBestBooks(period: "7")

    print(JsonConverter.prettified(result))
  }

  func testGetBestBooksByMonth() throws {
    let result = try subject.getBestBooks(period: "30")

    print(JsonConverter.prettified(result))
  }

  func testGetBestBooks() throws {
    let result = try subject.getBestBooks(period: "all")

    print(JsonConverter.prettified(result))
  }

  func testGetAuthorBooks() throws {
    let result = try subject.getAuthors()
    let items = result["items"] as! [Any]

    let id = (items[0] as! [String: String])["id"]!

    let result2 = try subject.getBooks(path: id)

    print(JsonConverter.prettified(result2))
  }

  func testGetPerformersBooks() throws {
    let result = try subject.getPerformers()
    let items = result["items"] as! [Any]

    let id = (items[0] as! [String: String])["id"]!

    let result2 = try subject.getBooks(path: id)

    print(JsonConverter.prettified(result2))
  }

  func testGetAuthors() throws {
    let result = try subject.getAuthors()

    print(JsonConverter.prettified(result))
  }

  func testGetPerformers() throws {
    let result = try subject.getPerformers()

    print(JsonConverter.prettified(result))
  }

  func testGetGenres() throws {
    let result1 = try subject.getGenres(page: 1)

    print(JsonConverter.prettified(result1))

    let result2 = try subject.getGenres(page: 2)

    print(JsonConverter.prettified(result2))
  }

  func testGetGenre() throws {
    let genres = try subject.getGenres(page: 1)

    let items = genres["items"] as! [Any]

    let id = (items[0] as! [String: String])["id"]!

    let result = try subject.getGenre(path: id)

    print(JsonConverter.prettified(result))
  }

  func testPagination() throws {
//    result = subject.getNewBooks(page: 1)
//
//    ap result
//
//    pagination = result[:pagination]
//
//    expect(pagination[:has_next]).to eq(true)
//    expect(pagination[:has_previous]).to eq(false)
//    expect(pagination[:page]).to eq(1)
//
//    result = subject.getNewBooks(page: 2)
//
//    ap result
//
//    pagination = result[:pagination]
//
//    expect(pagination[:has_next]).to eq(true)
//    expect(pagination[:has_previous]).to eq(true)
//    expect(pagination[:page]).to eq(2)
  }

  func testGetAudioTracks() throws {
//    path = "http://audioknigi.club/alekseev-gleb-povesti-i-rasskazy"
//
//    result = subject.getAudioTracks(path)
//
//    ap result
  }

  func testSearch() throws {
    let query = "пратчетт"

    let result = try subject.search(query: query)

    print(JsonConverter.prettified(result))
  }

  func testGrouping() throws {
    let data: Data? = Files.readFile("authors.json")

    let authors = JSON(data: data!)

    let result = subject.groupItemsByLetter(JsonConverter.convertToArray(authors) as! [[String: String]])

    print(result)
  }

  func testGenerateAuthorsList() throws {
    //try subject.generateAuthorsList("authors.json")
  }

  func testGeneratePerformersList() throws {
    //try subject.generatePerformersList("preformers.json")
  }
}
