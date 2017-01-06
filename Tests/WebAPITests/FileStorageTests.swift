import XCTest
import SwiftyJSON

@testable import WebAPI

class FileStorageTests: XCTestCase {
  var subject: FileStorage!

  override func setUp() {
    subject = FileStorage(NSHomeDirectory() + "/test_storage.json")
  }

  override func tearDown() {
    do {
      try FileStorage.removeFile(subject.fileName)
    }
    catch {
      print("Error removing file.")
    }
  }

  func testExistIfNotExists() {
    XCTAssertEqual(subject.exist(), false)
  }

  func testExistIfExists() throws {
    guard FileStorage.createFile(subject.fileName) else {
      print("Cannot create file.")

      XCTAssertEqual(false, true)

      return
    }

    XCTAssertEqual(subject.exist(), true)

    try FileStorage.removeFile(subject.fileName)

    XCTAssertEqual(subject.exist(), false)
  }

  func testLoad() throws {
    let items = ["item1": ["name": "name1", "age": "30"], "item2": ["name": "name2", "age": "35"]]

    guard FileStorage.createFile(subject.fileName, data: JsonConverter.toData(items)) else {
      print("Cannot create file.")

      XCTAssertEqual(false, true)

      return
    }

    XCTAssertEqual(subject.exist(), true)

    //let content = FileStorage.readFile(subject.fileName)

//    let result = String(data: content!, encoding: String.Encoding.utf8)
//    print(JsonConverter.prettified(result))

    XCTAssertEqual(subject.items.count, 0)

    subject.load()

    XCTAssertEqual(subject.items.count, 2)

   // print(subject.items)

//    var newItems: [String: Any] = [:]
//
//    for (key, value) in subject.items {
//      newItems[key] = JSON(value)
//    }
//
//    print(newItems)

    try FileStorage.removeFile(subject.fileName)
  }

  func testSave() {
    let items = ["name": "name1", "age": "30"]

    guard FileStorage.createFile(subject.fileName, data: JsonConverter.toData(items)) else {
      print("Cannot create file.")

      XCTAssertEqual(false, true)

      return
    }

    XCTAssertEqual(subject.items.count, 0)

    subject.save()

    //XCTAssertEqual(subject.items.count, 2)
    //
    //    removeFile(subject.fileName)
  }

}
