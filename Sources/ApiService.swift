import Foundation
import Alamofire

open class ApiService: AuthService {
  public var config: Config

  public var authorizeCallback: () -> Void = {}

  let apiUrl: String
  let userAgent: String
  
  init(config: Config, apiUrl: String, userAgent: String, authUrl: String, clientId: String,
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
      activationUrl = config.items["activation_url"]! as! String
      userCode = config.items["user_code"]! as! String
      deviceCode = config.items["device_code"]! as! String

      return (userCode: userCode, deviceCode: deviceCode, activationUrl: activationUrl)
    }
    else {
      let acResponse = getActivationCodes(includeClientSecret: includeClientSecret)
      
      if !acResponse.isEmpty {
        userCode = acResponse["user_code"]!
        deviceCode = acResponse["device_code"]!
        activationUrl = acResponse["activation_url"]!
        
        config.save([
          "user_code": userCode,
          "device_code": deviceCode,
          "activation_url": activationUrl
        ])
        
        return (userCode: userCode, deviceCode: deviceCode, activationUrl: activationUrl)
      }
      else {
        print("Error getting activation codes")
        
        return (userCode: "", deviceCode: "", activationUrl: "")
      }
    }
  }

  func checkAccessData(_ key: String) -> Bool {
    if key == "device_code" {
      return (config.items[key] != nil)
    }
    else {
      return (config.items[key] != nil) && (config.items["expires"] != nil) &&
        config.items["expires"]! as! String >= String(Int(Date().timeIntervalSince1970))
    }
  }
  
  public func checkToken() -> Bool {
    if checkAccessData("access_token") {
      return true
    }
    else if config.items["refresh_token"] != nil {
      let refreshToken = config.items["refresh_token"]
      
      let response = updateToken(refreshToken: refreshToken! as! String)
      
      config.save(response)
      
      return true
    }
    else if checkAccessData("device_code") {
      let deviceCode = config.items["device_code"]
      
      var response = createToken(deviceCode: deviceCode! as! String)
      
      response["device_code"] = deviceCode as? String
      
      config.save(response)
      
      return false
    }
    else {
      return false
    }
  }
  
  func fullRequest(path: String, method: HTTPMethod = .get, parameters: [String: String] = [:],
                   unauthorized: Bool=false) -> Data? {
    var result: Data?

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

      accessPath = accessPath.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

      let response = apiRequest(baseUrl: apiUrl, path: accessPath, method: method, parameters: parameters)

      if (response!.response!.statusCode == 401 || response!.response!.statusCode == 400) && !unauthorized {
        let refreshToken = config.items["refresh_token"]

        let response = updateToken(refreshToken: refreshToken! as! String)

        if !response.isEmpty {
          config.save(response)

          result = fullRequest(path: path, method: method, parameters: parameters, unauthorized: true)
        }
        else {
          print("error")
        }
      }
      else {
        result = response!.data
      }
    }

    return result
  }
  
}
