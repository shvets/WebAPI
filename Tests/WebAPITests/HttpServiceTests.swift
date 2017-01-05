import XCTest

@testable import WebAPI

class HttpServiceTests: XCTestCase {
  var subject = HttpService()

  func testHttpRequest() {
    let url = "http://httpbin.org/get"
    let response = subject.httpRequest(url: url)

    //print(response)

    XCTAssertEqual(response.ok, true)
    XCTAssertEqual(response.statusCode, 200)
  }

  static var allTests: [(String, (HttpServiceTests) -> () throws -> Void)] {
    return [
        ("testHttpRequest", testHttpRequest),
    ]
  }

}

