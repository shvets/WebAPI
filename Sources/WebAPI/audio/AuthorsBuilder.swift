import Foundation
import SwiftSoup

extension BookZvookAPI {
  class AuthorsBuilder {
    func build(document: Document) throws -> [Author] {
      var data: [Author] = []

      let table = try document.select("div[id=main-col] div[id=content] article div[class=entry-container fix]")

      let root = try table.select("div[class=entry fix]").array()[0]

      // first book

      let spanLinks = try root.select("table tr td > span").array()

      if spanLinks.count > 0 {
        let (name, books) = try processFirstBlock(links: spanLinks)

        if !name.isEmpty {
          data.append(Author(name: name, books: books))
        }
      }
      else {
        let name = try root.select("span > span > b > span").array()[0].parent()!.select("span").text()

        var books: [Book] = []

        let spanLinks2 = try table.select("div[class=entry fix] > span")

        if spanLinks2.array().count > 0 {
          let links = try spanLinks2.select("a")

          for link in links.array() {
            let href = try link.attr("href")
            let title = try link.text()

            books.append(Book(title: title, id: href))
          }

          if !name.isEmpty {
            data.append(Author(name: name, books: books))
          }
        }
      }

      // other books

      let pLinks = try root.select("p")

      for pLink in pLinks.array() {
        let links = try pLink.select("a").array()

        if links.count > 0 {
          let (name, books) = try processPBlock(path: "span > span > b > span", element: pLink, links: links)

          if !name.isEmpty {
            data.append(Author(name: name, books: books))
          }
          else {
            let (name, books) = try processPBlock(path: "b > span", element: pLink, links: links)

            if !name.isEmpty {
              data.append(Author(name: name, books: books))
            }
          }
        }
      }

      return data
    }

    func processFirstBlock(links: [Element]) throws -> (String, [Book]) {
      var name = ""
      var books: [Book] = []

      let firstSpanLink = links[0]

      name = try firstSpanLink.select("b > span").text()

      let siblings = firstSpanLink.siblingElements().array()

      var firstPTag = false

      for sibling in siblings {
        if sibling.tagName() == "span" && !firstPTag {
          let links = try sibling.select("a").array()

          for link in links {
            let href = try link.attr("href")
            let title = try link.text()

            books.append(Book(title: title, id: href))
          }
        }
        else if sibling.tagName() == "p" {
          firstPTag = true
        }
      }

      return (name, books)
    }

    func processPBlock(path: String, element: Element, links: [Element]) throws -> (String, [Book]) {
      var books: [Book] = []

      let name = try element.select(path).text()

      for link in links {
        let href = try link.attr("href")
        let title = try link.text()

        books.append(Book(title: title, id: href))
      }

      return (name, books)
    }
  }
}