import Foundation
import Alamofire

open class ApiService: AuthService {
  public var config: PlainConfig

  public var authorizeCallback: () -> Void = {}

  let apiUrl: String
  let userAgent: String
  
  init(config: PlainConfig, apiUrl: String, userAgent: String, authUrl: String, clientId: String,
       clientSecret: String, grantType: String, scope: String) {
    self.config = config
    
    self.config.load()
    
    self.apiUrl = apiUrl
    self.userAgent = userAgent
    
    super.init(authUrl: authUrl, clientId: clientId, clientSecret: clientSecret,
               grantType: grantType, scope: scope)
  }

  public func authorize(authorizeCallback: @escaping () -> Void) {
    self.authorizeCallback = authorizeCallback
  }
  
  public func resetToken() {
    _ = config.remove("access_token")
    _ = config.remove("refresh_token")
    _ = config.remove("device_code")
    _ = config.remove("user_code")
    _ = config.remove("activation_url")
    
    config.save()
  }
  
  func apiRequest(baseUrl: String, path: String, method: HTTPMethod?,
                  headers: [String: String] = [:], parameters: [String: String]) -> DataResponse<Data>? {
    let url = baseUrl + path
    
    var newHeaders = headers
    
    newHeaders["User-agent"] = userAgent
    
    return httpRequest(url, headers: newHeaders, parameters: parameters, method: method!)
  }
  
  public func authorization(includeClientSecret: Bool=true) -> (userCode: String, deviceCode: String, activationUrl: String) {
    var activationUrl: String
    var userCode: String
    var deviceCode: String

    if checkAccessData("device_code") && checkAccessData("user_code") {
      activationUrl = config.items["activation_url"]!
      userCode = config.items["user_code"]!
      deviceCode = config.items["device_code"]!

      return (userCode: userCode, deviceCode: deviceCode, activationUrl: activationUrl)
    }
    else {
      if let acResponse = getActivationCodes(includeClientSecret: includeClientSecret) {
        userCode = acResponse.userCode!
        deviceCode = acResponse.deviceCode!
        activationUrl = acResponse.activationUrl!

        config.items = [
          "user_code": userCode,
          "device_code": deviceCode,
          "activation_url": activationUrl
        ]
        
        config.save()

        return (userCode: userCode, deviceCode: deviceCode, activationUrl: activationUrl)
      }
    }

    print("Error getting activation codes")

    return (userCode: "", deviceCode: "", activationUrl: "")
  }

  func checkAccessData(_ key: String) -> Bool {
    if key == "device_code" {
      return (config.items[key] != nil)
    }
    else {
      return (config.items[key] != nil) && (config.items["expires"] != nil) &&
        config.items["expires"]! >= String(Int(Date().timeIntervalSince1970))
    }
  }
  
  public func checkToken() -> Bool {
    if checkAccessData("access_token") {
      return true
    }
    else if config.items["refresh_token"] != nil {
      let refreshToken = config.items["refresh_token"]
      
      if let response = updateToken(refreshToken: refreshToken!) {
        config.items = response.asDictionary()
        config.save()

        return true
      }
    }
    else if checkAccessData("device_code") {
      let deviceCode = config.items["device_code"]
      
      if let response = createToken(deviceCode: deviceCode!) {
        config.items = response.asDictionary()
        config.save()

        return false
      }
    }

    return false
  }
  
  func fullRequest(path: String, method: HTTPMethod = .get, parameters: [String: String] = [:],
                   unauthorized: Bool=false) -> DataResponse<Data>? {
    var response: DataResponse<Data>?

    if !checkToken() {
      authorizeCallback()
    }

    if let accessToken = config.items["access_token"] {
      var accessPath: String

      if path.characters.index(of: "?") != nil {
        accessPath = "\(path)&access_token=\(accessToken)"
      }
      else {
        accessPath = "\(path)?access_token=\(accessToken)"
      }

      if let accessPath = accessPath.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
        if let apiResponse = apiRequest(baseUrl: apiUrl, path: accessPath, method: method, parameters: parameters),
           let statusCode = apiResponse.response?.statusCode {
          if (statusCode == 401 || statusCode == 400) && !unauthorized {
            let refreshToken = config.items["refresh_token"]

            if let updateResult = updateToken(refreshToken: refreshToken!) {
              config.items = updateResult.asDictionary()
              config.save()

              response = fullRequest(path: path, method: method, parameters: parameters, unauthorized: true)
            }
            else {
              print("error")
            }
          }
          else {
            response = apiResponse
          }
        }
      }
    }

    return response
  }
  
}
