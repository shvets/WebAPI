import Foundation

open class KinoKongAPI: HttpService {
  static let SiteUrl = "http://kinokong.cc"
  let UserAgent = "KinoKong User Agent"

  public func available() throws -> Bool {
    let document = try fetchDocument(KinoKongAPI.SiteUrl, headers: getHeaders())

    return try document!.select("div[id=container]").size() > 0
  }

  func getHeaders() -> [String: String] {
    return [
      "User-Agent": UserAgent
    ]
  }

  func getPagePath(path: String, page: Int=1) -> String {
    if page == 1 {
      return path
    }
    else {
      return "\(path)page\(page)/"
    }
  }

}
