@testable import EtvnetAPI

import XCTest

XCTMain([
  testCase(ConfigTests.allTests),
  testCase(HttpServiceTests.allTests),
  testCase(EtvnetServiceAuthTests.allTests),
  testCase(EtvnetServiceTests.allTests)
])
