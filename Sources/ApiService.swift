import Foundation
import Just

open class ApiService : AuthService {
  public var config: Config
  
  let api_url: String
  let user_agent: String
  
  init(config: Config, api_url: String, user_agent: String, auth_url: String, client_id: String,
       client_secret: String, grant_type: String, scope: String) {
    self.config = config
    
    self.config.load()
    
    self.api_url = api_url
    self.user_agent = user_agent
    
    super.init(auth_url: auth_url, client_id: client_id, client_secret: client_secret,
               grant_type: grant_type, scope: scope)
  }
  
  public func resetToken() {
    _ = config.remove("access_token")
    _ = config.remove("refresh_token")
    _ = config.remove("device_code")
    _ = config.remove("user_code")
    _ = config.remove("activation_url")
    
    config.save()
  }
  
  func apiRequest(base_url: String, path: String, method: String?,
                  headers: [String: String] = [:], data: [String: String]) -> HTTPResult {
    let url = base_url + path
    
    var newHeaders = headers
    
    newHeaders["User-agent"] = user_agent
    
    return httpRequest(url: url, headers: newHeaders, data: data, method: method!)
  }
  
  public func authorization(include_client_secret: Bool=true) -> (user_code: String, device_code: String, activation_url: String) {
    var activation_url: String
    var user_code: String
    var device_code: String
    
    if checkAccessData("device_code") && checkAccessData("user_code") {
      activation_url = config.items["activation_url"]! as! String
      user_code = config.items["user_code"]! as! String
      device_code = config.items["device_code"]! as! String

      return (user_code: user_code, device_code: device_code, activation_url: activation_url)
    }
    else {
      let ac_response = getActivationCodes(include_client_secret: include_client_secret)
      
      if ac_response.count > 0 {
        user_code = ac_response["user_code"]!
        device_code = ac_response["device_code"]!
        activation_url = ac_response["activation_url"]!
        
        config.save([
          "user_code": user_code,
          "device_code": device_code,
          "activation_url": activation_url
        ])
        
        return (user_code: user_code, device_code: device_code, activation_url: activation_url)
      }
      else {
        print("Error getting activation codes")
        
        return (user_code: "", device_code: "", activation_url: "")
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
      let refresh_token = config.items["refresh_token"]
      
      let response = updateToken(refresh_token: refresh_token! as! String)
      
      config.save(response)
      
      return true
    }
    else if checkAccessData("device_code") {
      let device_code = config.items["device_code"]
      
      var response = createToken(device_code: device_code! as! String)
      
      response["device_code"] = device_code as? String
      
      config.save(response)
      
      return false
    }
    else {
      return false
    }
  }
  
  func fullRequest(path: String, method: String? = "get", data: [String: String] = [:],
                   unauthorized: Bool=false) -> Data? {
    var result: Data?

    if let access_token = config.items["access_token"] {
      var access_path: String
      
      if path.characters.index(of: "?") != nil {
        access_path = "\(path)&access_token=\(access_token)"
      }
      else {
        access_path = "\(path)?access_token=\(access_token)"
      }
      
      access_path = access_path.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
      
      let response = apiRequest(base_url: api_url, path: access_path, method: method, data: data)
      
      result = response.content
    }

    return result
  }
  
}
