import XCTest

@testable import EtvnetAPI

class StorageTests: XCTestCase {
  var subject = Storage()

  func testAdd() {
    subject.add(key: "name", value: "30")

    XCTAssertEqual(subject.items.count, 1)
  }

  func testRemove() {
    subject.add(key: "name", value: "30")
    subject.remove("name")

    XCTAssertEqual(subject.items.count, 0)
  }

  func testLoad() {
    class StorageMock : Storage {
      override func loadStorage() -> [String: Any]  {
        return ["name": "name1", "age": "30"];
      }
    }

    let subject = StorageMock()

    subject.load()

    XCTAssertEqual(subject.items.count, 2)
  }

  func testSave() {
    class StorageMock : Storage {
      override func saveStorage(_ items: [String: Any])  {
        self.items = ["name": "name1", "age": "30"];
      }
    }

    let subject = StorageMock()

    subject.save()

    XCTAssertEqual(subject.items.count, 2)
  }

}
