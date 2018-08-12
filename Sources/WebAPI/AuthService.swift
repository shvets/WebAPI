import Foundation
import Alamofire

public struct ActivationCodesProperties: Codable {
  public var deviceCode: String?
  public var userCode: String?
  public var activationUrl: String?

  enum CodingKeys: String, CodingKey {
    case deviceCode = "device_code"
    case userCode = "user_code"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    deviceCode = try container.decodeIfPresent(String.self, forKey: .deviceCode)
    userCode = try container.decodeIfPresent(String.self, forKey: .userCode)
    activationUrl = "device/usercode"
  }
}

public struct AuthProperties: Codable {
  public var accessToken: String?
  public var refreshToken: String?
  public var expiresIn: Int?

  private var expires: Int?

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case expiresIn = "expires_in"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
    refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
    expiresIn = try container.decodeIfPresent(Int.self, forKey: .expiresIn)

    if let expiresIn = expiresIn {
      expires = Int(Date().timeIntervalSince1970) + expiresIn
    }
  }

  public func asDictionary() -> [String: String] {
    var dict = [String: String]()

    if let accessToken = accessToken {
      dict["access_token"] = accessToken
    }

    if let refreshToken = refreshToken {
      dict["refresh_token"] = refreshToken
    }

    if let expires = expires{
      dict["expires"] = String(expires)
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
  
  func getActivationCodes(includeClientSecret: Bool = true, includeClientId: Bool = false) -> ActivationCodesProperties? {
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
            var result = try data.decoded() as ActivationCodesProperties

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
            result = try data.decoded() as AuthProperties
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
            result = try data.decoded() as AuthProperties
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
  
}
