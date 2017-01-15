import Foundation
import SwiftyJSON
import SwiftSoup

open class GidOnlineAPI: HttpService {
  public let URL = "http://gidonline.club"
  let USER_AGENT = "Gid Online User Agent"

  let SESSION_URL1 = "http://pandastream.cc/sessions/create_new"
  let SESSION_URL2 = "http://pandastream.cc/sessions/new"

//  public func available() throws -> Elements {
//    let document = try fetchDocument(URL)
//
//    return try document!.select("div[class='container'] div[class='row']")
//  }

  func sessionUrl() -> String {
    return SESSION_URL1
  }

  func getPagePath(path: String, page: Int=1) -> String {
    var newPath: String

    if page == 1 {
      newPath = path
    }
    else {
      var params = [String: String]()
      params["p"] = String(page)

      newPath = "\(path)page/\(page)/"
    }

    return newPath
  }

  public func getGenres(document: Document, type: String="") throws -> [Any] {
    var data: [Any] = []

    let links = try document.select("div[id='catline'] li a")

    for link: Element in links.array() {
      let path = try link.attr("href")
      var name = try link.attr("title")

//      let index1 = name.startIndex
//      let index2 = name.index(name.endIndex, offsetBy: -18)
//      name = name[index1 ..< index2]

      //    path = link.xpath('@href')[0].text
//    name = link.xpath('text()')[0].text
//
//    list << {"path": path, "name": name[0] + name[1..-1].downcase}

      data.append(["path": path, "name":name])
    }

    let family_group = [
      data[14],
      data[15],
      data[12],
      data[8],
      data[10],
      data[5],
      data[13]
    ]

    let crime_group = [
      data[4],
      data[9],
      data[2],
      data[0]
    ]

    let fiction_group = [
      data[20],
      data[19],
      data[17],
      data[18]
    ]

    let education_group = [
      data[1],
      data[7],
      data[3],
      data[6],
      data[11],
      data[16]
    ]

    switch type {
      case "Family":
        return family_group
      case "Crime":
        return crime_group
      case "Fiction":
        return fiction_group
      case "Education":
        return education_group
    default:
        return family_group + crime_group + fiction_group + education_group
    }
  }

  public func getTopLinks(document: Document) throws -> [Any] {
    var data: [Any] = []

    let links = try document.select("div[id='topls'] a[class='toplink']")
    //links = document.xpath('//div[@id="topls"]/a[@class="toplink"]')

    for link: Element in links.array() {
      let path = try link.attr("href")
      let name = try link.attr("title")
      let thumb = URL

//      path = link.xpath('@href')[0].text
//      name = link.xpath('text()')[0].text
//      thumb = URL + (link.xpath('img')[0].xpath("@src"))[0]
//
//      list << {"path": path, "name": name, "thumb": thumb}

      data.append(["path": path, "name": name, "thumb": thumb])
    }

    return data
  }

  public func getActors(document: Document, letter: String="") throws -> [Any] {
    var data: [Any] = []

//    all_list = fix_name(get_category('actors-dropdown', document))
//
//    all_list.sort_by! {|item| item[:name]}
//
//    if letter
//    list = []
//
//    all_list.each do |item|
//    if item[:name][0] == letter
//    list << item
//end
//end
//else
//list = all_list
//end
//
//fix_path(list)

    return data
  }

  public func getDirectors(document: Document, letter: String="") throws -> [Any] {
    var data: [Any] = []

//    all_list = fix_name(get_category('director-dropdown', document))
//
//    all_list.sort_by! {|item| item[:name]}
//
//    if letter
//    list = []
//
//    all_list.each do |item|
//    if item[:name][0] == letter
//    list << item
//end
//end
//else
//list = all_list
//end
//
//fix_path(list)

    return data
  }

//  func getCountries(document: Document) -> String {
//    return fixPath(getCategory("country-dropdown", document))
//  }
//
//  func getYears(document: Document) -> String {
//    return fixPath(getCategory("year-dropdown", document))
//  }
//
//  func getSeasons(document: Document) -> String {
//    return getCategory("season", getMovieDocument(URL + path))
//  }
//
//  func getSeasons(document: Document) -> String {
//    return getCategory("episode", getMovieDocument(URL + path))
//  }

  func getHeaders(referer: String) -> [String: String] {
    return [
      "User-Agent": USER_AGENT,
      "Referer": referer
    ]
  }

}
