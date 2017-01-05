import XCTest

@testable import WebAPI

class AuthAPITests: XCTestCase {
  let config = Config(configName: "etvnet.config")
  
  var subject = EtvnetAPI(config: Config(configName: "etvnet.config"))
  
  func testGetActivationCodes() {
    let result = subject.getActivationCodes()
    
    let activation_url = result["activation_url"]
    let user_code = result["user_code"]
    
    print("Activation url: \(activation_url!)")
    print("Activation code: \(user_code!)")
    
    XCTAssertNotNil(result["activation_url"]!)
    XCTAssertNotNil(result["user_code"]!)
    XCTAssertNotNil(result["device_code"]!)
  }
  
  func skipped_testCreateToken() {
    let result = subject.authorization()
  
    if result.user_code != "" {
      let response = subject.tryCreateToken(
          user_code: result.user_code,
          device_code: result.device_code,
          activation_url: result.activation_url
      )
          
      XCTAssertNotNil(response["access_token"]!)
      XCTAssertNotNil(response["refresh_token"]!)
    }
  }
  
  func skipped_testUpdateToken() {
    let refresh_token = subject.config.items["refresh_token"]! as! String
    
    let response = subject.updateToken(refresh_token: refresh_token)
    
    subject.config.save(response)
    
    //print(response)
    
    XCTAssertNotNil(response["access_token"]!)
  }
}
