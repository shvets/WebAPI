import XCTest

@testable import WebAPI

class AudioBooAPITests: XCTestCase {
  var subject = AudioBooAPI()

  func testGetLetters() throws {
    let result = try subject.getLetters()

    print(result as Any)
  }

  func testGetAuthorsByLetters() throws {
    let letters = try subject.getLetters()

    let id = letters[0]["id"]!

    let result = try subject.getAuthorsByLetter(id)

    print(result as Any)
  }

  func testGetBooks() throws {
    let letters = try subject.getLetters()

    let letterId = letters[0]["id"]!

    let authors = try subject.getAuthorsByLetter(letterId)

    let url = (authors[0].value as! [NameClassifier.Item])[0].id

    let result = try subject.getBooks(url)

    print(result as Any)
  }

  func testGetPlaylistUrls() throws {
    let letters = try subject.getLetters()

    let letterId = letters[0]["id"]!

    let authors = try subject.getAuthorsByLetter(letterId)

    let url = (authors[4].value as! [NameClassifier.Item])[0].id
    //url = 'http://audioboo.ru/geimannil/1009-geyman-nil-koralina.html'

    let books = try subject.getBooks(url)

    //print(books)

    let bookId = (books[0] as! [String: String])["id"]

    let result = try subject.getPlaylistUrls(bookId!)

    print(result as Any)
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

    let url = "http://audioboo.ru/xfsearch/%C3%E5%E9%E4%E5%F0+%C4%FD%E2%E8%E4/"

    let books = try subject.getBooks(url)

    let bookId = (books[0] as! [String: String])["id"]

    let playlistUrls = try subject.getPlaylistUrls(bookId!)

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
