import XCTest

@testable import WebAPI

class FileStorageTests: XCTestCase {
  var subject: FileStorage!

  override func setUp() {
    subject = FileStorage(NSHomeDirectory() + "/test_storage.json")
  }

  override func tearDown() {
    do {
      try Files.removeFile(subject.fileName)
    }
    catch {
      print("Error removing file.")
    }
  }

  func testExistIfNotExists() {
    XCTAssertEqual(subject.exist(), false)
  }

  func testExistIfExists() throws {
    guard Files.createFile(subject.fileName) else {
      print("Cannot create file.")

      XCTAssertEqual(false, true)

      return
    }

    XCTAssertEqual(subject.exist(), true)

    try Files.removeFile(subject.fileName)

    XCTAssertEqual(subject.exist(), false)
  }

  func testLoad() throws {
    let items = ["item1": ["name": "name1", "age": "30"], "item2": ["name": "name2", "age": "35"]]

    guard Files.createFile(subject.fileName, data: JsonConverter.toData(items)) else {
      print("Cannot create file.")

      XCTAssertEqual(false, true)

      return
    }

    XCTAssertEqual(subject.exist(), true)
    XCTAssertEqual(subject.items.count, 0)

    subject.load()

    XCTAssertEqual(subject.items.count, 2)

    try Files.removeFile(subject.fileName)
  }

  func testSave() {
    let items = ["name": "name1", "age": "30"]

    guard Files.createFile(subject.fileName, data: JsonConverter.toData(items)) else {
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
