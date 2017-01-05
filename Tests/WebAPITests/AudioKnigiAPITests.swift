import XCTest
import SwiftyJSON

@testable import WebAPI

class AudioKnigiAPITests: XCTestCase {
  var subject = AudioKnigiAPI()

  func testAuthorsLetters() throws {
    let result = try subject.getAuthorsLetters()

    //print(JsonConverter.prettified(result))
  }

  func testPerformersLetters() throws {
    let result = try subject.getPerformersLetters()

    //print(JsonConverter.prettified(result))
  }

  func testGetNewBooks() throws {
    let result = try subject.getNewBooks()

    //print(JsonConverter.prettified(result))
  }

}
