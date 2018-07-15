import XCTest

@testable import WebAPI

class BookZvookAPITests: XCTestCase {
  var subject =  BookZvookAPI()

  func testGetLetters() throws {
    let result = try subject.getLetters()

    print(result as Any)
  }

  func testGetAuthorsByLetter() throws {
    let letters = try subject.getLetters()

//    print(letters as Any)

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
  }

  func testGetPlaylistUrls() throws {
    let url = "http://bookzvuk.ru/zhizn-i-neobyichaynyie-priklyucheniya-soldata-ivana-chonkina-1-litso-neprikosnovennoe-vladimir-voynovich-audiokniga-onlayn/"

    let result = try self.subject.getPlaylistUrls(url)

    print(result as Any)
  }

  func testGetAudioTracks() throws {
    let url = "http://bookzvuk.ru/zhizn-i-neobyichaynyie-priklyucheniya-soldata-ivana-chonkina-1-litso-neprikosnovennoe-vladimir-voynovich-audiokniga-onlayn/"

    let playlistUrls = try subject.getPlaylistUrls(url)
    
    //print(playlistUrls)

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
