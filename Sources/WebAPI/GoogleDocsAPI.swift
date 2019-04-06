import Foundation
import SwiftSoup

open class GoogleDocsAPI: HttpService {
//  let SiteUrl = "http://cyro.se"
//  let UserAgent = "Google Docs User Agent"
//
//  func available() throws -> Elements {
//    let document = try fetchDocument(SiteUrl, headers: getHeaders())
//
//    return try document!.select("td.topic_content")
//  }
//
//  func getMovies(page: Int=1) throws -> ItemsList {
//    return try getCategory(category: "movies", page: page)
//  }
//
//  func getSeries(page: Int=1) throws -> ItemsList {
//    return try getCategory(category: "tvseries", page: page)
//  }
//
//  func getLatestEpisodes(page: Int=1) throws -> ItemsList {
//    return try getCategory(category: "episodes", page: page)
//  }
//
//  func getLatest(page: Int=1) throws -> ItemsList {
//    return try getCategory(category: "", page: page)
//  }
//
//  func getCategory(category: String="", page: Int=1) throws -> ItemsList {
//    var data = [Any]()
//    var paginationData: ItemsList = [:]
//
//    var pagePath: String = ""
//
//    if category != "" {
//      pagePath = "/\(category)/index.php?" + "page=\(page)"
//    }
//    else {
//      pagePath = "/index.php?show=latest-topics&" + "page=\(page)"
//    }
//
//    let document = try fetchDocument(SiteUrl + pagePath, headers: getHeaders())
//
//    let items = try document!.select("td.topic_content")
//
//    for item in items.array() {
//      let href = try item.select("div a").attr("href")
//
//      var path: String?
//
//      if category != "" {
//        path = "/\(category)/\(href)"
//      }
//      else {
//        path = "/\(href)"
//      }
//
//      let name = try item.select("div a img").attr("alt")
//      let urlPath = try item.select("div a img").attr("src")
//      let thumb = SiteUrl + urlPath
//
//      data.append(["path": path!, "thumb": thumb, "name": name])
//    }
//
//    if items.size() > 0 {
//      paginationData = try extractPaginationData(pagePath, page: page)
//    }
//
//    return ["movies": data, "pagination": paginationData]
//  }
//
//  func getGenres(page: Int=1) throws -> ItemsList {
//    var data = [Any]()
//
//    let document = try fetchDocument(SiteUrl + "/movies/genre.php?showC=27", headers: getHeaders())
//
//    let items = try document!.select("td.topic_content")
//
//    for item in items.array() {
//      let href = try item.select("div a").attr("href")
//      let src = try item.select("div a img").attr("src")
//
//      let path = "/movies/\(href)"
//      let thumb = "\(SiteUrl)\(src)"
//
//      let fileName = thumb.components(separatedBy: "/").last!
//      let index1 = fileName.startIndex
//
//      let name = fileName[index1 ..< fileName.find("-")!]
//
//      data.append(["path": path, "thumb": thumb, "name": name])
//    }
//
//    return ["movies": data]
//  }
//
//  func getGenre(path: String, page: Int=1) throws -> ItemsList {
//    var data = [Any]()
//    var paginationData: ItemsList = [:]
//
//    let response = httpRequest(SiteUrl + getCorrectedPath(path), headers: getHeaders())
//
//    let newPath = "\(response!.response!.url!.path)?\(response!.response!.url!.query!)"
//
//    let pagePath = newPath + "&page=\(page)"
//
//    let document = try fetchDocument(SiteUrl + pagePath, headers: getHeaders())
//
//    let items = try document!.select("td.topic_content")
//
//    for item in items.array() {
//      let href = try item.select("div a").attr("href")
//
//      let path = "/movies/" + href
//      let name = try item.select("div a img").attr("alt")
//      let urlPath = try item.select("div a img").attr("src")
//      let thumb = SiteUrl + urlPath
//
//      data.append(["path": path, "thumb": thumb, "name": name])
//    }
//
//    if items.size() > 0 {
//      paginationData = try extractPaginationData(pagePath, page: page)
//    }
//
//    return ["movies": data, "pagination": paginationData]
//  }
//
//  func getSerie(path: String, page: Int=1) throws -> ItemsList {
//    var data = [Any]()
//
//    let document = try fetchDocument(SiteUrl + path, headers: getHeaders())
//
//    let items = try document!.select("div.titleline h2 a")
//
//    for item in items.array() {
//      let href = try item.attr("href")
//
//      let path = "/forum/" + href
//      let name = try item.text()
//
//      data.append(["path": path, "name": name])
//    }
//
//    return ["movies": data]
//  }
//
//  func getPreviousSeasons(_ path: String) throws -> ItemsList {
//    var data = [Any]()
//
//    let document = try fetchDocument(SiteUrl + path, headers: getHeaders())
//
//    let items = try document!.select("div.titleline h2 a")
//
//    for item in items.array() {
//      let href = try item.attr("href")
//
//      let path = "/forum/" + href
//      let name = try item.text()
//
//      data.append(["path": path, "name": name])
//    }
//
//    return ["movies": data]
//  }
//
////  func getSeasons(path: String) throws -> ItemsList {
////    let data = try self.getPreviousSeasons(path)
////
//////    let currentSeason = try getSeason(path)
//////
//////    let firstItemName = currentSeason[0]["name"]
//////    let index1 = firstItemName.find("Season")
//////    let index2 = firstItemName.find("Episode")
//////
//////    let number = first_item_name[index1+6:index2].strip()
//////
//////    data.append(["path": path, "name": "Season " + number])
////
////    return data
////  }
//
////  func getSeason(_ path: String) throws -> ItemsList {
////    var data = [Any]()
////
//////    let document = try fetchDocument(SiteUrl + getCorrectedPath(path), headers: getHeaders())
//////
//////    let items = try document!.select("div.inner h3 a")
//////
//////    for item in items.array() {
//////      let href = try item.attr("href")
//////
//////      let path = "/forum/" + href
//////      let name = try item.text()
//////
//////      if name.find("Season Download") < 1 {
//////        let newName = extractName(name)
//////
//////        data.append(["path": path, "name": newName])
//////      }
//////    }
////
////    return ["movies": data]
////  }
//
//  func updateUrls(data: [String: Any], url: String) -> [Any] {
//    var urls = data["urls"] as! [Any]
//
//    urls.append(url)
//
//    return urls
//  }
//
//  func getMovie(_ id: String) throws -> [String: Any] {
//    var data = [String: Any]()
//
//    let response = httpRequest(SiteUrl + id, headers: getHeaders())
//
//    let url = response!.response!.url!
//
//    let document = try fetchDocument(url.absoluteString, headers: getHeaders())
//
//    let name = try document!.select("title").text()
//
//    data["name"] = extractName(name)
//    data["thumb"] = SiteUrl + (try document!.select("img[id='nameimage']").attr("src"))
//
//    data["urls"] = []
//
//    let frameUrl1 = try document!.select("iframe").attr("src")
//
//    if frameUrl1 != "" {
//      let data1 = try fetchDocument(SiteUrl + frameUrl1, headers: getHeaders())
//
//      let frameUrl2 = try data1!.select("iframe").attr("src")
//
//      let data2 = try fetchDocument(SiteUrl + frameUrl2, headers: getHeaders())
//
//      let url1 = try data2!.select("iframe").attr("src")
//
//      data["urls"] = updateUrls(data: data, url: url1)
//
//      let components = frameUrl2.components(separatedBy: ".")
//
//      let frameUrl2WithoutExt = components[0...components.count-2].joined(separator: ".")
//
//      if !frameUrl2WithoutExt.isEmpty {
//        let secondUrlPart2 = frameUrl2WithoutExt + "2.php"
//
//        do {
//          let data3 = try fetchDocument(SiteUrl + secondUrlPart2, headers: getHeaders())
//
//          let url2 = try data3!.select("iframe").attr("src")
//
//          data["urls"] = updateUrls(data: data, url: url2)
//        }
//        catch {
//           // suppress
//        }
//
//        do {
//          let secondFrameUrlPart3 = frameUrl2WithoutExt + "3.php"
//
//          let data4 = try fetchDocument(SiteUrl + secondFrameUrlPart3, headers: getHeaders())
//
//          let url3 = try data4!.select("iframe").attr("src")
//
//          if !url3.isEmpty {
//            data["urls"] = updateUrls(data: data, url: url3)
//          }
//        }
//        catch {
//          // suppress
//        }
//      }
//    }
//
////    if document.select("iframe[contains(@src,'ytid=')]/@src")) > 0 {
////      let el = SiteUrl + document!.xpath("//iframe[contains(@src,'ytid=')]/@src")[0]
////
////      //data["trailer_url"] = el.split("?",1)[0].replace("http://dayt.se/bits/pastube.php", "https://www.youtube.com/watch?v=") + el.split("=",1)[1]
////    }
//
//    return data
//  }
//
//  func extractPaginationData(_ path: String, page: Int) throws -> ItemsList {
////    let document = try fetchDocument(SiteUrl + path, headers: getHeaders())
////
////    var pages = 1
////
////    let paginationRoot = try document?.select("div.mainpagination table tr")
////
////    if paginationRoot != nil {
////      let paginationBlock = paginationRoot!.get(0)
////
////      let items = try paginationBlock.select("td.table a")
////
////      pages = items.size()
////    }
////
////    return [
////      "page": page,
////      "pages": pages,
////      "has_previous": page > 1,
////      "has_next": page < pages
////    ]
//
//    return [:]
//  }
//
//  func getCorrectedPath(_ path: String) -> String {
//    let id = getMediaId(path)
//
//    let index1 = path.startIndex
//    let index21 = path.find("goto-")
//
//    return path[index1 ..< index21!] + "view.php?id=\(id)"
//  }
//
//  func getMediaId(_ path: String) -> String {
//    let index11 = path.find("/goto-")
//
//    let index1 = path.index(index11!, offsetBy: 6)
//
//    let idPart = String(path[index1 ..< path.endIndex])
//
//    let index3 = idPart.startIndex
//    let index41 = idPart.find("-")
//
//    return String(idPart[index3 ..< index41!])
//  }
//
//  func extractName(_ name: String) -> String {
//    //return name.rsplit(" Streaming", 1)[0].rsplit(" Download", 1)[0]
//    return name
//  }
//
//  func getHeaders() -> [String: String] {
//    return [
//      "User-Agent": UserAgent
//    ]
//  }

}
