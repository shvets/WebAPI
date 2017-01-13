import XCTest
import SwiftyJSON

@testable import WebAPI

class AudioKnigiAPITests: XCTestCase {
  var subject = AudioKnigiAPI()

  func testAuthorsLetters() throws {
    _ = try subject.getAuthorsLetters()

    //print(JsonConverter.prettified(result))
  }

  func testPerformersLetters() throws {
    _ = try subject.getPerformersLetters()

    //print(JsonConverter.prettified(result))
  }

  func testGetNewBooks() throws {
    _ = subject.getNewBooks()

    //print(JsonConverter.prettified(result))
  }

}
