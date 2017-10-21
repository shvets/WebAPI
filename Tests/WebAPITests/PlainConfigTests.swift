import XCTest
import Files

@testable import WebAPI

class PlainConfigTests: XCTestCase {
  var subject = PlainConfig(Folder.current.path + "config-test.config")

  func testSave() {
    do {
      try File(path: subject.fileName).delete()
    }
    catch {
      print("Error deleting config file")
    }

    let data = ["key1": "value1", "key2": "value2"]

    subject.items = data

    subject.save()

    XCTAssertEqual(subject.items.keys.count, 2)
  }

  func testLoad() {
    do {
      let data = "{\"key1\": \"value1\", \"key2\": \"value2\"}".data(using: .utf8)

      print("[\"key1\": \"value1\", \"key2\": \"value2\"]")

      try FileSystem().createFile(at: subject.fileName, contents: data!)
    }
    catch {
      print("Error creating config file")
    }

    subject.load()

    XCTAssertEqual(subject.items.keys.count, 2)
  }

}
