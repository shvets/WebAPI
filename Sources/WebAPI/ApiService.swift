import Foundation
import Alamofire
import ConfigFile

open class ApiService: AuthService {
  public var config: StringConfigFile

  public var authorizeCallback: () -> Void = {}

  let apiUrl: String
  let userAgent: String
  
  init(config: StringConfigFile, apiUrl: String, userAgent: String, authUrl: String, clientId: String,
       clientSecret: String, grantType: String, scope: String) {
    self.config = config
    
    self.apiUrl = apiUrl
    self.userAgent = userAgent
    
    super.init(authUrl: authUrl, clientId: clientId, clientSecret: clientSecret,
               grantType: grantType, scope: scope)

    self.loadConfig()
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

    saveConfig()
  }

  func loadConfig() {
    do {
      try config.load()
    }
    catch let error {
      print("Error loading configuration: \(error)")
    }
  }

  func saveConfig() {
    do {
      try config.save()
    }
    catch let error {
      print("Error saving configuration: \(error)")
    }
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

        saveConfig()

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
        saveConfig()

        return true
      }
    }
    else if checkAccessData("device_code") {
      let deviceCode = config.items["device_code"]
      
      if let response = createToken(deviceCode: deviceCode!) {
        config.items = response.asDictionary()
        saveConfig()

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
        let headers = ["User-agent": userAgent]

        if let apiResponse = httpRequest(apiUrl + accessPath, headers: headers, parameters: parameters, method: method),
           let statusCode = apiResponse.response?.statusCode {
          if (statusCode == 401 || statusCode == 400) && !unauthorized {
            let refreshToken = config.items["refresh_token"]

            if let updateResult = updateToken(refreshToken: refreshToken!) {
              config.items = updateResult.asDictionary()
              saveConfig()

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
