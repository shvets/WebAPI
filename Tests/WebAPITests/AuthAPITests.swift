import XCTest

@testable import WebAPI

class AuthAPITests: XCTestCase {
  let config = Config(configName: "etvnet.config")
  
  var subject = EtvnetAPI(config: Config(configName: "etvnet.config"))
  
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
  
  func skipped_testCreateToken() {
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
  
  func skipped_testUpdateToken() {
    let refreshToken = subject.config.items["refresh_token"]!
    
    let response = subject.updateToken(refreshToken: refreshToken)
    
    subject.config.save(response!.asDictionary())
    
    XCTAssertNotNil(response!.accessToken)
  }
}
