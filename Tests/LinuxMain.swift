@testable import EtvnetAPI

import XCTest

XCTMain([
  testCase(HttpServiceTests.allTests),
  testCase(AuthAPITests.allTests),
  testCase(EtvnetAPITests.allTests)
])
