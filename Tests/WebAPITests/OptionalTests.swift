import XCTest

@testable import WebAPI

class LiveBeing {}

class Bird: LiveBeing {
  let wings: Int?;

  init(_ wings: Int) {
    self.wings = wings
  }
}

class Animal: LiveBeing {
  let legs: Int?;

  init(_ legs: Int) {
    self.legs = legs
  }
}

class Host {
  var liveBeing: LiveBeing?

  init(_ liveBeing: LiveBeing?) {
    self.liveBeing = liveBeing
  }
}

extension Optional where Wrapped == LiveBeing {
  mutating func get<T: LiveBeing>(orSet expression: @autoclosure () -> T) -> T {
    guard let being = self as? T else {
      let newBeing = expression()
      self = newBeing

      return newBeing
    }

    return being
  }
}

class OptionalTests: XCTestCase {

  func test1() throws {
    var data: String? = nil

    XCTAssertEqual(data.isNilOrEmpty, true)

    data = "abc"

    XCTAssertEqual(data.isNilOrEmpty, false)
  }

  func test2() throws {
    let data: String? = "abc"

    XCTAssertEqual(data.matching { $0.count > 2 }, "abc")
    XCTAssertEqual(data.matching { $0.count > 3 }, nil)
  }

  func test3() throws {
    let b1 = Bird(2) as LiveBeing

    let host1 = Host(b1)

    XCTAssertEqual(host1.liveBeing.get(orSet: Bird(6)).wings, 2)

    let b2: LiveBeing? = nil

    let host2 = Host(b2)

    XCTAssertEqual(host2.liveBeing.get(orSet: Bird(6)).wings, 6)
  }

}
