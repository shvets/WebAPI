import Foundation
import Just

open class AuthService: HttpService {
  var auth_url: String
  var client_id: String
  var client_secret: String
  var grant_type: String
  var scope: String
  
  init(auth_url: String, client_id: String, client_secret: String, grant_type: String, scope: String) {
    self.auth_url = auth_url
    self.client_id = client_id
    self.client_secret = client_secret
    self.grant_type = grant_type
    self.scope = scope
  }
  
  func getActivationCodes(include_client_secret: Bool = true, include_client_id: Bool = false) -> [String: String] {
    var data = ["scope": scope]
    
    if include_client_secret {
      data["client_secret"] = client_secret
    }
    
    if include_client_id {
      data["client_id"] = client_id
    }

    var result: [String: String] = [:]
    
    let httpResult = authRequest(query: &data, rtype: "device/code", method: "get")
    
    if httpResult.ok {
      if let content = httpResult.content {
        result = JsonConverter.toItems(content) as! [String: String]
        
        result["activation_url"] = auth_url + "device/usercode"
      }
    }
    
    return result
  }
  
  public func createToken(device_code: String) -> [String: String] {
    var data: [String: String] = ["grant_type": grant_type, "code": device_code]
    
    let httpResult = authRequest(query: &data)
    
    var result: [String: String] = [:]
    
    if httpResult.ok {
      result = JsonConverter.toItems(httpResult.content!) as! [String: String]
    }
    
    return result
  }
  
  func updateToken(refresh_token: String) -> [String: String] {
    var data = ["grant_type": "refresh_token", "refresh_token": refresh_token]
    
    var result: [String: String] = [:]
    
    let httpResult = authRequest(query: &data)
    
    if httpResult.ok {
      result = addExpires(JsonConverter.toItems(httpResult.content!) as! [String: String])
    }
    
    return result
  }
  
  func authRequest(query: inout [String: String], rtype: String="token", method: String="get") -> HTTPResult {
    query["client_id"] = client_id
    
    if rtype == "token" {
      query["client_secret"] = client_secret
    }
    
    let url = auth_url + rtype
    
    return httpRequest(url: url, query: query, method: method)
  }
  
  func addExpires(_ data: [String: String]) -> [String: String] {
    var newData = data
    
    if let expires_in = newData["expires_in"] {
      newData["expires"] = String(Int(Date().timeIntervalSince1970) + Int(expires_in)!)
    }
    
    return newData
  }
  
}
