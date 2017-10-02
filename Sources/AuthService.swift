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
    var parameters = ["scope": scope]
    
    if includeClientSecret {
      parameters["client_secret"] = clientSecret
    }
    
    if includeClientId {
      parameters["client_id"] = clientId
    }

    var result = [String: String]()
    
    if let response = authRequest(parameters: parameters, rtype: "device/code", method: .get) {
      if response.result.isSuccess {
        if let data = response.data {
          do {
            let decoder = JSONDecoder()

            result = try decoder.decode([String: String].self, from: data)
          }
          catch {
          }

          result["activation_url"] = authUrl + "device/usercode"
        }
      }
    }
    
    return result
  }
  
  public func createToken(deviceCode: String) -> [String: String] {
    let parameters: [String: String] = ["grant_type": grantType, "code": deviceCode]

    var result = [String: String]()

    if let response = authRequest(parameters: parameters) {
      if response.result.isSuccess {
        if let data = response.data {
          do {
            let decoder = JSONDecoder()

            result = try decoder.decode([String: String].self, from: data)
          }
          catch {
          }
        }
      }
    }

    return result
  }
  
  func updateToken(refreshToken: String) -> [String: String] {
    let data = ["grant_type": "refresh_token", "refresh_token": refreshToken]
    
    var result = [String: String]()
    
    if let response = authRequest(parameters: data) {
      if response.result.isSuccess {
        if let data = response.data {
          do {
            let decoder = JSONDecoder()

            result = try decoder.decode([String: String].self, from: data)
          }
          catch {
          }
        }
      }
    }
    
    return result
  }
  
  func authRequest(parameters: [String: String], rtype: String="token", method: HTTPMethod = .get) -> DataResponse<Data>? {
    var newParameters = parameters.reduce(into: [:], { dict, elem in dict[elem.key] = elem.value })

    newParameters["client_id"] = clientId
    
    if rtype == "token" {
      newParameters["client_secret"] = clientSecret
    }
    
    let url = authUrl + rtype
    
    return httpRequest(url, parameters: newParameters, method: method)
  }
  
  func addExpires(_ data: [String: String]) -> [String: String] {
    var newData = data
    
    if let expiresIn = newData["expires_in"] {
      newData["expires"] = String(Int(Date().timeIntervalSince1970) + Int(expiresIn)!)
    }
    
    return newData
  }
  
}
