import XCTest
import SwiftyJSON
import Wrap
import Unbox

@testable import WebAPI

class MuzArbuzAPITests: XCTestCase {
  var subject = MuzArbuzAPI()

  func testGetAlbums() throws {
    let result = try subject.getAlbums(["limit": "20"])

    print(JsonConverter.prettified(result["objects"]))
  }

  func testGetAlbumContainer() throws {
    let result = try subject.getAlbums(["parent_id": "14485"])

    print(JsonConverter.prettified(result["objects"]))
  }

  func testGetAlbumsByYearRange() throws {
    let result = try subject.getAlbums(["year__gte": "2014", "year__lte": "2015"])

    print(JsonConverter.prettified(result["objects"]))
  }

  func testGetArtistTracks() throws {
    let result = try subject.getTracks(["artists": "1543"])

    print(JsonConverter.prettified(result["objects"]))
  }

  func testGetAlbumTracks() throws {
    let result = try subject.getTracks(["album": "14486"])

    print(JsonConverter.prettified(result["objects"]))
  }

  func testGetCollectionTracks() throws {
    let result = try subject.getTracks(["collection__id": "115"])

    print(JsonConverter.prettified(result["objects"]))
  }

  func testGetArtists() throws {
    let result = try subject.getArtists()

    print(JsonConverter.prettified(result["objects"]))
  }

  func testGetArtistAnnotated() throws {
    let result = try subject.getArtistAnnotated(["title__istartswith": "В"])

    print(JsonConverter.prettified(result["objects"]))
  }

  func testGetCollections() throws {
    let result = try subject.getCollections(["limit": "25"])

    print(JsonConverter.prettified(result["objects"]))
  }

  func testGetGenres() throws {
    let result = try subject.getGenres()

    print(JsonConverter.prettified(result["objects"]))
  }

  func testGetAlbumsByGenre() throws {
    let result = try subject.getAlbums(["genre__in": "1"])

    print(JsonConverter.prettified(result["objects"]))
  }

  func testSearch() throws {
    let result = try subject.search(query: "макаревич")

    print(result)
  }

}


