import XCTest
import SwiftyJSON
import Wrap
import Unbox

@testable import WebAPI

class AudioBooAPITests: XCTestCase {
  var subject = AudioBooAPI()

  func testGetLetters() throws {
    let result = try subject.getLetters()

    print(JsonConverter.prettified(result))
  }

  func testGetAuthorsByLetters() throws {
    let letters = try subject.getLetters()

    let id = (letters[0] as! [String: String])["id"]!

    let result = try subject.getAuthorsByLetter(id)

    print(result)
    //print(JsonConverter.prettified(result))
  }

  func testGetBooks() throws {
//    let letters = try subject.getLetters()
//    print(letters)
//
//    let authors = subject.getAuthorsByLetter(letters[0]["id"])
//
//
//    let result = subject,getBooks(authors[authors.keys()[1]][0]["id"])
//
////    let id = (items[0] as! [String: String])["id"]!
//
//    print(JsonConverter.prettified(result))
  }

}
