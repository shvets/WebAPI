import XCTest
import ConfigFile

@testable import WebAPI

class AuthAPITests: XCTestCase {
  static var config = StringConfigFile("etvnet.config")
  
  var subject = EtvnetAPI(config: config)
  
  func testGetActivationCodes() {
    let result = subject.getActivationCodes()!
    
    let activationUrl = result.activationUrl!
    let userCode = result.userCode!
    
    print("Activation url: \(activationUrl)")
    print("Activation code: \(userCode)")
    
    XCTAssertNotNil(result.activationUrl)
    XCTAssertNotNil(result.userCode)
    XCTAssertNotNil(result.deviceCode)
  }
  
  func testCreateToken() {
    let result = subject.authorization()

    if result.userCode != "" {
      let response = subject.tryCreateToken(
          userCode: result.userCode,
          deviceCode: result.deviceCode,
          activationUrl: result.activationUrl
      )!

      XCTAssertNotNil(response.accessToken)
      XCTAssertNotNil(response.refreshToken)
    }
  }
  
  func testUpdateToken() throws {
    let refreshToken = subject.config.items["refresh_token"]!
    
    let response = subject.updateToken(refreshToken: refreshToken)

    subject.config.items = response!.asDictionary()

    try subject.config.save()
    
    XCTAssertNotNil(response!.accessToken)
  }
}
