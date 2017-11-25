import Alamofire
import Foundation

class OAuth2Handler: RequestRetrier {
  private let apiService: ApiService;

  private var isRefreshing = false

  public init(_ apiService: ApiService) {
    self.apiService = apiService
  }
  
  func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
    if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401,
           response.statusCode == 400 {
      let refreshToken = self.apiService.config.items["refresh_token"]!

      print("need to refresh")
      print(response.statusCode)

      if let result = self.apiService.updateToken(refreshToken: refreshToken) {
        self.apiService.config.items = result.asDictionary()
        self.apiService.saveConfig()
      }
    }
    else {
      completion(false, 0.0)
    }
  }
  
}

