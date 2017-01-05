import Foundation
import SwiftyJSON
import SwiftSoup

open class AudioKnigiAPI : HttpService {
  let URL = "https://audioknigi.club"

  func getPagePath(path: String, page: Int=1) -> String {
    return "\(path)page\(page)/"
  }

  func getAuthorsLetters() throws -> [Any] {
    return try getLetters(path: "/authors/", filter: "author-prefix-filter")
  }

  func getPerformersLetters() throws -> [Any] {
    return try getLetters(path: "/performers/", filter: "performer-prefix-filter")
  }

  func getLetters(path: String, filter: String) throws -> [Any] {
    let data: [Any] = []

    let document = try fetchDocument(URL + path)

    let items = try document!.select("ul[id='" + filter + "'] li a")

    for item in items.array() {
      let name = try item.text()

      //data << name
    }

    return data
  }

  func getNewBooks(page: Int=1) -> [Any]  {
    return getBooks(path: "/index/", page: page)
  }

  func get_best_books(period: String, page:Int=1) -> [Any] {
    return getBooks(path:"/index/views/", period: period, page: page)
  }

  func getBooks(path: String, period: String="", page: Int=1) -> [Any] {
//    let path = URI.decode(path)
//
//    let page_path = getPagePath(path, page)
//
//    if period != "" {
//      page_path = page_path + "?period=" + period
//    }
//
//    let document = try fetchDocument(url: URL + page_path)
//
//    return getBookItems(document, path=path, page=page)

    return []
  }

  func getBookItems(document: Document, path: String, page: Int) {
//    data = []
//
//    items = document.xpath("//article")
//
//    items.each do |item|
//    link = item.xpath("header/h3/a").first
//
//    name = link.content
//    href = link.xpath("@href").text
//    thumb = item.xpath("img").attr("src").text
//    description = item.xpath("div[@class="topic-content text"]").children.first.content.strip
//
//    data << {"type": "book", "name": name, "path": href, "thumb": thumb, "description": description}
//  }
//
//pagination = extract_pagination_data(document: document, path: path, page: page)
//
//{"items": data, "pagination": pagination}
  }

  func get_authors(page: Int=1) {
    return getCollection(path: "/authors/", page: page)
  }

  func getPerformers(page: Int=1) {
    return getCollection(path: "/performers/", page: page)
  }

  func getCollection(path: String, page: Int=1) {
//    data = []
//
//    page_path = get_page_path(path, page)
//
//    document = fetch_document(url: URL + page_path, encoding: "utf-8")
//
//    items = document.xpath("//td[@class="cell-name"]")
//
//    items.each do |item|
//    link = item.xpath("h4/a").first
//
//    name = link.text
//    href = link.attr("href")[URL.length..-1] + "/"
//
//    data << {"name": name, "path": URI.decode(href)}
//  }
//
//pagination = extract_pagination_data(document: document, path: path, page: page)
//
//{"items": data, "pagination": pagination}
  }

  func get_genres(page: Int=1) {
//    data = []
//
//    path = "/sections/"
//
//    page_path = get_page_path(path, page)
//
//    document = fetch_document(url: URL + page_path, encoding: "utf-8")
//
//    items = document.xpath("//td[@class="cell-name"]")
//
//    items.each do |item|
//    link = item.xpath("a").first
//
//    name = item.xpath("h4/a").first.text
//    href = link.attr("href")[URL.length]
//    thumb = link.xpath("img").attr("src")
//
//    data << {"name": name, "path": href, "thumb": thumb}
//  }
//
//pagination = extract_pagination_data(document: document, path: path, page: page)
//
//{"items": data, "pagination": pagination}
  }

  func get_genre(path: String, page: Int=1) -> [Any] {
    return getBooks(path: path, page: page)
  }

  func get_audio_tracks(url: String) {

  }

  func generate_authors_list(file_name: String) {

  }

  func generate_performers_list(file_name: String) {

  }

  func group_items_by_letter(items: [Any]) {

  }

  func merge_small_groups(groups: [Any]) {

  }

  func starts_with_different_letter(list: [Any], name: String) {

  }

  func extractPaginationData(_ path: String, selector: String, page: Int) throws -> Items {
//    pages = 1
//
//    pagination_root = document.xpath("//div[@class="paging"]")
//
//    if pagination_root and pagination_root.length > 0
//    pagination_block = pagination_root[0]
//
//    items = pagination_block.xpath("ul/li")
//
//    last_link = items[items.length - 2].xpath("a")
//
//    if last_link.size == 0
//    last_link = items[items.length - 3].xpath("a")
//
//    pages = last_link.text.to_i
//else
//href = last_link.attr("href").text
//
//pattern = path + "page"
//
//index1 = href.index(pattern)
//index2 = href.index("/?")
//
//unless index2
//index2 = href.length-1
//}
//
//pages = href[index1+pattern.length..index2].to_i
//}
//}
//
//{
//  "page": page,
//  "pages": pages,
//  "has_previous": page > 1,
//  "has_next": page < pages,
//}


    let document = try fetchDocument(URL + path)

    var pages = 1

    let paginationRoot = try document?.select("div[class='" + selector + "'] ~ div[class='row']")

    if paginationRoot != nil {
      let paginationBlock = paginationRoot!.get(0)

      let text = try paginationBlock.text()

      let index11 = text.find(":")
      let index21 = text.find("(")

      if index11 != nil && index21 != nil {
        let index1 = text.index(index11!, offsetBy: 1)

        let items = Int(text[index1 ..< index21!].trim())

        pages = items! / 24

        if items! % 24 > 0 {
          pages = pages + 1
        }
      }
    }

    return [
      "page": page,
      "pages": pages,
      "has_previous": page > 1,
      "has_next": page < pages,
    ]
  }
}
