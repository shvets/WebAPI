import Foundation
import Alamofire

public struct AuthProperties: Codable {
  public var deviceCode: String?
  public var activationUrl: String?
  public var userCode: String?
  public var accessToken: String?
  public var refreshToken: String?

  enum CodingKeys: String, CodingKey {
    case deviceCode = "device_code"
    case activationUrl = "activation_url"
    case userCode = "user_code"
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
  }

  public init(deviceCode: String="", activationUrl: String="", userCode: String="",
              accessToken: String="", refreshToken: String="") {
    self.deviceCode = deviceCode
    self.activationUrl = activationUrl
    self.userCode = userCode
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }

  public func asDictionary() -> [String: String] {
    var dict = [String: String]()

    if let deviceCode = deviceCode {
      dict["device_code"] = deviceCode
    }

    if let activationUrl = activationUrl {
      dict["activation_url"] = activationUrl
    }

    if let userCode = userCode {
      dict["user_code"] = userCode
    }

    if let accessToken = accessToken {
      dict["access_token"] = accessToken
    }

    if let refreshToken = refreshToken {
      dict["refresh_token"] = refreshToken
    }

    return dict
  }
}


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
  
  func getActivationCodes(includeClientSecret: Bool = true, includeClientId: Bool = false) -> AuthProperties? {
    var parameters = ["scope": scope]
    
    if includeClientSecret {
      parameters["client_secret"] = clientSecret
    }
    
    if includeClientId {
      parameters["client_id"] = clientId
    }

    if let response = authRequest(parameters: parameters, rtype: "device/code", method: .get) {
      if response.result.isSuccess {
        if let data = response.data {
          do {
            let decoder = JSONDecoder()

            var result = try decoder.decode(AuthProperties.self, from: data)

            result.activationUrl = authUrl + "device/usercode"

            return result
          }
          catch let e {
            print("Error: \(e)")
          }
        }
      }
    }
    
    return nil
  }
  
  public func createToken(deviceCode: String) -> AuthProperties? {
    let parameters: [String: String] = ["grant_type": grantType, "code": deviceCode]

    var result: AuthProperties?

    if let response = authRequest(parameters: parameters) {
      if response.result.isSuccess {
        if let data = response.data {
          do {
            let decoder = JSONDecoder()

            result = try decoder.decode(AuthProperties.self, from: data)
          }
          catch let e {
            print("Error: \(e)")
          }
        }
      }
    }

    return result
  }
  
  func updateToken(refreshToken: String) -> AuthProperties? {
    let data = ["grant_type": "refresh_token", "refresh_token": refreshToken]
    
    var result: AuthProperties?
    
    if let response = authRequest(parameters: data) {
      if response.result.isSuccess {
        if let data = response.data {
          do {
            let decoder = JSONDecoder()

            result = try decoder.decode(AuthProperties.self, from: data)
          }
          catch let e {
            print("Error: \(e)")
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
