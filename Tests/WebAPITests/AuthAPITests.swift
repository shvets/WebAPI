import XCTest

@testable import WebAPI

class AuthAPITests: XCTestCase {
  let config = Config(configName: "etvnet.config")
  
  var subject = EtvnetAPI(config: Config(configName: "etvnet.config"))
  
  func testGetActivationCodes() {
    let result = subject.getActivationCodes()
    
    let activationUrl = result["activation_url"]
    let userCode = result["user_code"]
    
    print("Activation url: \(activationUrl!)")
    print("Activation code: \(userCode!)")
    
    XCTAssertNotNil(result["activation_url"]!)
    XCTAssertNotNil(result["user_code"]!)
    XCTAssertNotNil(result["device_code"]!)
  }
  
  func skipped_testCreateToken() {
    let result = subject.authorization()
  
    if result.userCode != "" {
      let response = subject.tryCreateToken(
          userCode: result.userCode,
          deviceCode: result.deviceCode,
          activationUrl: result.activationUrl
      )
          
      XCTAssertNotNil(response["access_token"]!)
      XCTAssertNotNil(response["refresh_token"]!)
    }
  }
  
  func skippedTestUpdateToken() {
    let refreshToken = subject.config.items["refresh_token"]! as! String
    
    let response = subject.updateToken(refreshToken: refreshToken)
    
    subject.config.save(response)
    
    //print(response)
    
    XCTAssertNotNil(response["access_token"]!)
  }
}
