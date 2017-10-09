import XCTest

@testable import WebAPI

class PlainConfigTests: XCTestCase {
  var subject = PlainConfig("config-test.config")

  func testSave() {
    let data = ["key1": "value1", "key2": "value2"]

    subject.items = data

    subject.save()

    XCTAssertEqual(subject.items.keys.count, 2)
  }

  func testLoad() {
    subject.load()

    XCTAssertEqual(subject.items.keys.count, 2)
  }

}