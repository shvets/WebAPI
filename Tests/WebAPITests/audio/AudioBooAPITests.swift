import XCTest

@testable import WebAPI

class AudioBooAPITests: XCTestCase {
  var subject = AudioBooAPI()

  func testGetLetters() throws {
    let result = subject.getLetters()

    print(result as Any)
  }

  func testGetAuthorsByLetters() throws {
    let exp = expectation(description: "Gets new books")

    _ = subject.getLetters().subscribe(onNext: { letters in
      //print(letters as Any)

      XCTAssert(letters.count > 0)

      let id = letters[0]["id"]!

      do {
        let result = try self.subject.getAuthorsByLetter(id)

        //print(result as Any)

        XCTAssert(result.count > 0)
      }
      catch let e {
        XCTFail(e.localizedDescription)
      }

      exp.fulfill()
    },
    onError: { error in
      print("Received error:", error)
    })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetBooks() throws {
    let exp = expectation(description: "Gets new books")

    _ = subject.getLetters().subscribe(onNext: { letters in
      //print(letters as Any)

      XCTAssert(letters.count > 0)

      do {
        let letterId = letters[0]["id"]!

        let authors = try self.subject.getAuthorsByLetter(letterId)

        let url = (authors[0].value as! [NameClassifier.Item])[0].id

        let result = try self.subject.getBooks(url)

        //print(result as Any)

        XCTAssert(result.count > 0)
      }
      catch let e {
        XCTFail(e.localizedDescription)
      }

      exp.fulfill()
    },
      onError: { error in
        print("Received error:", error)
      })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetPlaylistUrls() throws {
    let exp = expectation(description: "Gets new books")

    _ = subject.getLetters().subscribe(onNext: { letters in
      //print(letters as Any)

      XCTAssert(letters.count > 0)

      do {
        let letterId = letters[0]["id"]!

        let authors = try self.subject.getAuthorsByLetter(letterId)

        let url = (authors[4].value as! [NameClassifier.Item])[0].id
        //url = 'http://audioboo.ru/geimannil/1009-geyman-nil-koralina.html'

        let books = try self.subject.getBooks(url)

        //print(books)

        let bookId = (books[0] as! [String: String])["id"]

        let result = try self.subject.getPlaylistUrls(bookId!)

        print(result as Any)
      }
      catch let e {
        XCTFail(e.localizedDescription)
      }

      exp.fulfill()
    },
    onError: { error in
      print("Received error:", error)
    })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetAudioTracks() throws {
//    let letters = try subject.getLetters()
//
//    let letterId = letters[3]["id"]!
//
//    let authors = try subject.getAuthorsByLetter(letterId)
//
//    //print(authors)
//
//    let url = (authors[4].value as! [NameClassifier.Item])[0].id
//
//    print(url)

    //let url = "http://audioboo.ru/xfsearch/%C3%E5%E9%E4%E5%F0+%C4%FD%E2%E8%E4/"

//    let books = try subject.getBooks(url)
//
//    let bookId = (books[0] as! [String: String])["id"]

    let url = "http://audioboo.ru/proza/21725-pelevin-viktor-iphuck-10.html"

    let playlistUrls = try subject.getPlaylistUrls(url)

    let list = try subject.getAudioTracks(playlistUrls[0])

    print(try Prettifier.prettify { encoder in
      return try encoder.encode(list)
    })

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testSearch() throws {
    let query = "пратчетт"

    let result = try subject.search(query)

    print(result as Any)
  }
}
