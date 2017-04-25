import Foundation

extension URLSession {

  public func withProxy(proxyURL: String, proxyPort: Int) -> URLSession {

    var configuration = self.configuration

    configuration.connectionProxyDictionary = [
      kCFNetworkProxiesHTTPEnable as AnyHashable : true,
      kCFNetworkProxiesHTTPPort as AnyHashable : proxyPort,
      kCFNetworkProxiesHTTPProxy as AnyHashable : proxyURL
    ]

//    let config = URLSessionConfiguration.default
//    config.requestCachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
//    config.connectionProxyDictionary = [AnyHashable: Any]()
//    config.connectionProxyDictionary?[kCFNetworkProxiesHTTPEnable as String] = 1
//    config.connectionProxyDictionary?[kCFNetworkProxiesHTTPProxy as String] = "176.221.42.213"
//    config.connectionProxyDictionary?[kCFNetworkProxiesHTTPPort as String] = 3130
//    config.connectionProxyDictionary?[kCFStreamPropertyHTTPSProxyHost as String] = "142.54.173.19"
//    config.connectionProxyDictionary?[kCFStreamPropertyHTTPSProxyPort as String] = 8888

    return URLSession(configuration: configuration, delegate: self.delegate, delegateQueue: self.delegateQueue)
  }
}