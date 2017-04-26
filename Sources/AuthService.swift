import Foundation
import Alamofire

open class AuthService: HttpService {
  var authUrl: String
  var clientId: String
  var clientSecret: String
  var grantType: String
  var scope: String
  
  init(authUrl: String, clientId: String, clientSecret: String, grantType: String, scope: String) {
    self.authUrl = authUrl
    self.clientId = clientId
    self.clientSecret = clientSecret
    self.grantType = grantType
    self.scope = scope
  }
  
  func getActivationCodes(includeClientSecret: Bool = true, includeClientId: Bool = false) -> [String: String] {
    var data = ["scope": scope]
    
    if includeClientSecret {
      data["client_secret"] = clientSecret
    }
    
    if includeClientId {
      data["client_id"] = clientId
    }

    var result = [String: String]()
    
    let httpResult = authRequest(parameters: &data, rtype: "device/code", method: .get)
    
    if httpResult!.response!.statusCode == 200 {
      if let data = httpResult!.data {
        result = JsonConverter.toItems(data) as! [String: String]
        
        result["activation_url"] = authUrl + "device/usercode"
      }
    }
    
    return result
  }
  
  public func createToken(deviceCode: String) -> [String: String] {
    var data: [String: String] = ["grant_type": grantType, "code": deviceCode]
    
    let httpResult = authRequest(parameters: &data)
    
    var result = [String: String]()
    
    if httpResult!.response!.statusCode == 200 {
      result = JsonConverter.toItems(httpResult!.data!) as! [String: String]
    }
    
    return result
  }
  
  func updateToken(refreshToken: String) -> [String: String] {
    var data = ["grant_type": "refresh_token", "refresh_token": refreshToken]
    
    var result = [String: String]()
    
    let httpResult = authRequest(parameters: &data)
    
    if httpResult!.response!.statusCode == 200 {
      result = addExpires(JsonConverter.toItems(httpResult!.data!) as! [String: String])
    }
    
    return result
  }
  
  func authRequest(parameters: inout [String: String], rtype: String="token", method: HTTPMethod = .get) -> DefaultDataResponse? {
    parameters["client_id"] = clientId
    
    if rtype == "token" {
      parameters["client_secret"] = clientSecret
    }
    
    let url = authUrl + rtype
    
    return httpRequest(url, parameters: parameters, method: method)
  }
  
  func addExpires(_ data: [String: String]) -> [String: String] {
    var newData = data
    
    if let expiresIn = newData["expires_in"] {
      newData["expires"] = String(Int(Date().timeIntervalSince1970) + Int(expiresIn)!)
    }
    
    return newData
  }
  
}
