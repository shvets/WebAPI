import Foundation
import Just

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
    
    let httpResult = authRequest(query: &data, rtype: "device/code", method: "get")
    
    if httpResult.ok {
      if let content = httpResult.content {
        result = JsonConverter.toItems(content) as! [String: String]
        
        result["activation_url"] = authUrl + "device/usercode"
      }
    }
    
    return result
  }
  
  public func createToken(deviceCode: String) -> [String: String] {
    var data: [String: String] = ["grant_type": grantType, "code": deviceCode]
    
    let httpResult = authRequest(query: &data)
    
    var result = [String: String]()
    
    if httpResult.ok {
      result = JsonConverter.toItems(httpResult.content!) as! [String: String]
    }
    
    return result
  }
  
  func updateToken(refreshToken: String) -> [String: String] {
    var data = ["grant_type": "refresh_token", "refresh_token": refreshToken]
    
    var result = [String: String]()
    
    let httpResult = authRequest(query: &data)
    
    if httpResult.ok {
      result = addExpires(JsonConverter.toItems(httpResult.content!) as! [String: String])
    }
    
    return result
  }
  
  func authRequest(query: inout [String: String], rtype: String="token", method: String="get") -> HTTPResult {
    query["client_id"] = clientId
    
    if rtype == "token" {
      query["client_secret"] = clientSecret
    }
    
    let url = authUrl + rtype
    
    return httpRequest(url: url, query: query, method: method)
  }
  
  func addExpires(_ data: [String: String]) -> [String: String] {
    var newData = data
    
    if let expiresIn = newData["expires_in"] {
      newData["expires"] = String(Int(Date().timeIntervalSince1970) + Int(expiresIn)!)
    }
    
    return newData
  }
  
}
