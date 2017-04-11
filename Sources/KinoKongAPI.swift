import Foundation
import SwiftSoup

open class KinoKongAPI: HttpService {
  static let SiteUrl = "http://kinokong.cc"
  let UserAgent = "KinoKong User Agent"

  public func available() throws -> Bool {
    let document = try fetchDocument(KinoKongAPI.SiteUrl, headers: getHeaders(), encoding: .windowsCP1251)

    return try document!.select("div[id=container]").size() > 0
  }

  public func getAllMovies(page: Int=1) throws -> Items {
    return try getMovies("/films/", page: page)
  }

  public func getMovies(_ path: String, page: Int=1) throws -> Items {
    var data = [Any]()
    var paginationData: Items = [:]

    let pagePath = getPagePath(path: path, page: page)

//    let document = try fetchDocument(KinoKongAPI.SiteUrl + pagePath, headers: getHeaders(), encoding: .windowsCP1251)
//
//    let items = try document!.select("div[class=owl-item] div")

//    for item: Element in items.array() {
//      let link = try item.select("a").get(0)
//      let href = try link.attr("href")
//
//      let name = try link.attr("title")

      //shadow_node = item.find('div[@class="main-sliders-shadow"]')
//title_node = item.find('div[@class="main-sliders-title"]')
//season_node = shadow_node.find('div/div[@class="main-sliders-season"]')
//bg_node = shadow_node.find('div/span[@class="main-sliders-bg"]')
//
//href_link = bg_node.find('a[@class="main-sliders-play"]')
//thumb_link = shadow_node.find('div/img')
//
//href = href_link.get('href')
//href = href[len(self.URL):]
//thumb = thumb_link.get('src')

      //if thumb.find(self.URL) == -1:
//thumb = self.URL + thumb
//name = title_node.text_content()
//
//data.append({'path': href, 'thumb': thumb, 'name': name, 'isSerie': season_node is not None})
//
//    }

    //pagination = self.extract_pagination_data(page_path, page=page)
//
//return {"items": data, "pagination": pagination["pagination"]}

    //if items.size() > 0 {
      //paginationData = try extractPaginationData(pagePath, selector: selector, page: page)
    //}

    return ["movies": data, "pagination": paginationData]
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
