import XCTest

@testable import WebAPI

class AudioBooAPITests: XCTestCase {
  var subject = AudioBooAPI()

  func testGetLetters() throws {
    let result = try subject.getLetters()

    print(JsonConverter.prettified(result))
  }

  func testGetAuthorsByLetters() throws {
    let letters = try subject.getLetters()

    let id = letters[0]["id"]!

    let result = try subject.getAuthorsByLetter(id)

    print(result)
  }

  func testGetBooks() throws {
    let letters = try subject.getLetters()

    let letterId = letters[0]["id"]!

    let authors = try subject.getAuthorsByLetter(letterId)

    let url = (authors[0].value as! [NameClassifier.Item])[0].id

    let result = try subject.getBooks(url)

    print(JsonConverter.prettified(result))
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

    print(result)
  }

  func testGetAudioTracks() throws {
    let letters = try subject.getLetters()

    let letterId = letters[0]["id"]!

    let authors = try subject.getAuthorsByLetter(letterId)

    let url = (authors[4].value as! [NameClassifier.Item])[0].id
    //url = 'http://audioboo.ru/geimannil/1009-geyman-nil-koralina.html'

    let books = try subject.getBooks(url)

    let bookId = (books[0] as! [String: String])["id"]

    let playlistUrls = try subject.getPlaylistUrls(bookId!)

    print(playlistUrls)

    let result = try subject.getAudioTracks(playlistUrls[0] as! String)

//    print(result)
    print(JsonConverter.prettified(result))
  }

  func testSearch() throws {
    let query = "пратчетт"

    let result = try subject.search(query)

    print(JsonConverter.prettified(result))
  }
}
