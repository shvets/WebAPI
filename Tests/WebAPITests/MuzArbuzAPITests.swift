import XCTest
import SwiftyJSON
import Wrap
import Unbox

@testable import WebAPI

class MuzArbuzAPITests: XCTestCase {
  var subject = MuzArbuzAPI()

  func testGetAlbums() throws {
    let result = try subject.getAlbums()

    print(JsonConverter.prettified(result))
  }

  func testGetAlbumContainer() throws {
    let result = try subject.getAlbums(params: ["parent_id": "14485"])

    print(JsonConverter.prettified(result["items"]))
  }

  func testGetAlbumsByYearRange() throws {
    let result = try subject.getAlbums(params: ["year__gte": "2014", "year__lte": "2015"])

    print(JsonConverter.prettified(result["items"]))
  }

  func testGetArtistTracks() throws {
    let result = try subject.getTracks(params: ["artists": "1543"])

    print(JsonConverter.prettified(result["items"]))
  }

  func testGetAlbumTracks() throws {
    let result = try subject.getTracks(params: ["album": "14486"])

    print(JsonConverter.prettified(result["items"]))
  }

  func testGetCollectionTracks() throws {
    let result = try subject.getTracks(params: ["collection__id": "115"])

    print(JsonConverter.prettified(result["items"]))
  }

  func testGetArtists() throws {
    let result = try subject.getArtists()

    print(JsonConverter.prettified(result["items"]))
  }

  func testGetArtistAnnotated() throws {
    let result = try subject.getArtistAnnotated(params: ["title__istartswith": "b"])

    print(JsonConverter.prettified(result["items"]))
  }

  func testGetCollections() throws {
    let result = try subject.getCollections()

    print(JsonConverter.prettified(result["items"]))
  }

  func testGetGenres() throws {
    let result = try subject.getGenres()

    print(JsonConverter.prettified(result["items"]))
  }

  func testGetAlbumsByGenre() throws {
    let result = try subject.getAlbums(params: ["genre__in": "1"])

    print(JsonConverter.prettified(result["items"]))
  }

  func testSearch() throws {
    let result = try subject.search(query: "макаревич")

    print(result)
  }

}


