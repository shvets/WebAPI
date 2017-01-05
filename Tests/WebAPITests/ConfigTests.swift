import XCTest

@testable import EtvnetAPI

class ConfigTests: XCTestCase {
  var subject = Config(configName: "etvnet-test.config")

  func testLoad() {
    subject.load()

    XCTAssertEqual(subject.items.keys.count, 2)
  }

  func testSave() {
    let data = ["key1": "value1", "key2": "value2"]

    subject.save(data)

    XCTAssertEqual(subject.items.keys.count, 2)
  }
}
