import XCTest

@testable import WebAPI

class BookZvookAPITests: XCTestCase {
  var subject =  BookZvookAPI()

  func testGetLetters() throws {
    let exp = expectation(description: "Get Letters")

    _ = try subject.getLetters().subscribe(onNext: { result in
      print(result as Any)

      XCTAssert(result.count > 0)

      exp.fulfill()
    },
      onError: { error in
        print("Received error:", error)
      })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetAuthorsByLetter() throws {
    let exp = expectation(description: "Get Letters")

    _ = try subject.getLetters().subscribe(onNext: { letters in
      print(letters as Any)

      XCTAssert(letters.count > 0)

      let id = letters[1]["id"]!

      do {
        let result = try self.subject.getAuthorsByLetter(id)

        print(result as Any)

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

  func testGetGenres() throws {
    let result = try subject.getGenres()

    print(result as Any)
  }

  func testGetPlaylistUrls() throws {
    let url = "http://bookzvuk.ru/zhizn-i-neobyichaynyie-priklyucheniya-soldata-ivana-chonkina-1-litso-neprikosnovennoe-vladimir-voynovich-audiokniga-onlayn/"

    let result = try self.subject.getPlaylistUrls(url)

    print(result as Any)
  }

  func testGetAudioTracks() throws {
    let url = "http://bookzvuk.ru/zhizn-i-neobyichaynyie-priklyucheniya-soldata-ivana-chonkina-1-litso-neprikosnovennoe-vladimir-voynovich-audiokniga-onlayn/"
    //let url = "http://bookzvuk.ru/zemlekopyi-terri-pratchett-audiokniga-onlayn/"
    let playlistUrls = try subject.getPlaylistUrls(url)
    
    //print(playlistUrls)

    let list = try subject.getAudioTracks(playlistUrls[0])

    print(try Prettifier.prettify { encoder in
      return try encoder.encode(list)
    })

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetBooks() throws {
    let exp = expectation(description: "Search")

    _ = try subject.getBooks(page: 2).subscribe(onNext: { result in
      print(result as Any)

      XCTAssert(result.count > 0)

      exp.fulfill()
    },
      onError: { error in
        print("Received error:", error)
      })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testSearch() throws {
    let query = "пратчетт"
    
    let exp = expectation(description: "Search")

    _ = try subject.search(query, page: 2).subscribe(onNext: { result in
      print(result as Any)

      XCTAssert(result.count > 0)

      exp.fulfill()
    },
      onError: { error in
        print("Received error:", error)
      })

    waitForExpectations(timeout: 10, handler: nil)
  }
}
