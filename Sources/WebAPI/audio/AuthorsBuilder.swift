import Foundation
import SwiftSoup

extension BookZvookAPI {
  class AuthorsBuilder {
    func build(document: Document) throws -> [Author] {
      var data: [Author] = []

      let table = try document.select("div[id=main-col] div[id=content] article div[class=entry-container fix]")

      let sections = try table.select("div[class=entry fix]")

      for section in sections.array() {
        let pLinks = try section.select("p")

        for pLink in pLinks.array() {
          var name = ""

          var books: [Book] = []

          var links = try pLink.select("a")

          if links.array().count > 0 {
            var authorNode = try pLink.select("span > span > b > span")

            name = try authorNode.text()

            for link in links.array() {
              let href = try link.attr("href")
              let title = try link.text()

              let book = Book(title: title, id: href)

              books.append(book)
            }
          }
          else {
            let firstSpan = try section.select("span").array()[0]

            var authorNode = try firstSpan.select("span > span > b > span")

            name = try authorNode.text()

            let link1 = try section.select("tr td")

            // print(link1.array().count)

            if link1.array().count > 0 {
              try grabFrom1(link: link1, books: &books)
            }
            else {
              try grabFrom2(section: section, books: &books)
            }
          }

          if name.isEmpty {
            print("Empty: \(books)")
          }

          data.append(Author(name: name, books: books))
        }
      }

      return data
    }

    func grabFrom2(section: Element, books: inout [Book]) throws {
      //              let link2 = try section.select("span > b > a")
//
//              print("--- \(link2.array().count)")

      for child in section.children().array() {

        //print("--- \(child.tagName())")

        if child.tagName() == "span" {
          let link = try child.select("a")

          let href = try link.attr("href")
          let title = try link.text()

          if !href.isEmpty {
            let book = Book(title: title, id: href)

            books.append(book)
          }
        }
      }
    }

    func grabFrom1(link: Elements, books: inout [Book]) throws {
      let links = link.array()[0]

      for child in links.children().array() {
        if child.tagName() == "span" {
          let link = try child.select("a")

          let href = try link.attr("href")
          let title = try link.text()

          if !href.isEmpty {
            let book = Book(title: title, id: href)

            books.append(book)
          }
        }
      }
    }

//  func getAuthorName(_ link: Element) throws -> String {
//    var authorNode = try link.select("span > span > b > span")
//
//    return try authorNode.text()
//  }
  }
}