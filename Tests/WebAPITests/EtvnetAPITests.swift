import XCTest
import ConfigFile

@testable import WebAPI

class EtvnetAPITests: XCTestCase {
  static var config = StringConfigFile("etvnet.config")

  var subject = EtvnetAPI(config: config)

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.

    subject.authorize {
      let result = self.subject.authorization()

      if result.userCode != "" {
        _ = self.subject.tryCreateToken(userCode: result.userCode, deviceCode: result.deviceCode, activationUrl: result.activationUrl)
      }
    }
  }

  func testGetChannels() throws {
    let channels = subject.getChannels()

    print(try channels.prettify())

    XCTAssertNotNil(channels)
    XCTAssert(channels.count > 0)
  }

  func testGetArchive() throws {
    let exp = expectation(description: "Gets archive")

    _ = subject.getArchive(channelId: 3).subscribe(
      onNext: { result in
        print(result as Any)

        XCTAssertNotNil(result)
        XCTAssert(result!.media.count > 0)
        XCTAssert(result!.pagination.count > 0)

        exp.fulfill()
      },
      onError: { error in
        print("Received error:", error)
      })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetGenre() throws {
    let exp = expectation(description: "Gets genre")

    _ = subject.getArchive(genre: 1).subscribe(
      onNext: { result in
        print(result as Any)

        XCTAssertNotNil(result)
        XCTAssert(result!.media.count > 0)
        XCTAssert(result!.pagination.count > 0)

        exp.fulfill()
      },
      onError: { error in
        print("Received error:", error)
      })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetNewArrivals() throws {
    let data = subject.getNewArrivals()!

    XCTAssertNotNil(data)
    XCTAssert(data.media.count > 0)
    XCTAssert(data.pagination.count > 0)
  }

//  func testGetBlockbusters() throws {
//    let exp = expectation(description: "Gets blockbusters")
//
//    _ = subject.getBlockbusters().subscribe(
//      onNext: { result in
//        print(result as Any)
//
//        XCTAssertNotNil(result)
//        XCTAssert(result!.media.count > 0)
//        XCTAssert(result!.pagination.count > 0)
//
//        exp.fulfill()
//      },
//      onError: { error in
//        print("Received error:", error)
//      })
//
//    waitForExpectations(timeout: 10, handler: nil)
//  }
//
//  func testGetCoolMovies() throws {
//    let exp = expectation(description: "Gets cool movies")
//
//    _ = subject.getCoolMovies(perPage: 15, page: 4).subscribe(
//      onNext: { result in
//        print(result as Any)
//
//        XCTAssertNotNil(result)
//        XCTAssert(result!.media.count > 0)
//        XCTAssert(result!.pagination.count > 0)
//
//        exp.fulfill()
//      },
//      onError: { error in
//        print("Received error:", error)
//      })
//
//    waitForExpectations(timeout: 10, handler: nil)
//  }

  func testGetGenres() throws {
    let list = subject.getGenres()

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testSearch() throws {
    let query = "news"
    let data = subject.search(query)!

    XCTAssertNotNil(data)
    XCTAssert(data.media.count > 0)
    XCTAssert(data.pagination.count > 0)
  }

  func testPagination() throws {
    let query = "news"

    let result1 = subject.search(query, perPage: 20, page: 1)!
    let pagination1 = result1.pagination

    XCTAssertEqual(pagination1.hasNext, true)
    XCTAssertEqual(pagination1.hasPrevious, false)
    XCTAssertEqual(pagination1.page, 1)

    let result2 = subject.search(query, perPage: 20, page: 2)!
    let pagination2 = result2.pagination

    XCTAssertEqual(pagination2.hasNext, true)
    XCTAssertEqual(pagination2.hasPrevious, true)
    XCTAssertEqual(pagination2.page, 2)
  }

  func testGetUrl() throws {
    let id = 760894 // 329678
    let  bitrate = "1200"
    let format = "mp4"

    let urlData = subject.getUrl(id, format: format, mediaProtocol: "hls", bitrate: bitrate)

    puts("Media Url: " + urlData["url"]!)

    //    #print("Play list:\n" + self.service.get_play_list(url_data["url"]))
  }

  func testGetLiveChannelUrl() throws {
    let id = 423
    let  bitrate = "800"
    let format = "mp4"

    let urlData = subject.getLiveChannelUrl(id, format: format, bitrate: bitrate)

    puts("Media Url: " + urlData["url"]!)

    //    #print("Play list:\n" + self.service.get_play_list(url_data["url"]))
  }

  func testGetMediaObjects() throws {
    let exp = expectation(description: "Gets media objects")

    _ = subject.getArchive(channelId: 3).subscribe(
      onNext: { result in
        var mediaObject: EtvnetAPI.Media? = nil

        for item in result!.media {
          let type = item.mediaType

          if type == .mediaObject {
            mediaObject = item
            break
          }
        }

        print(mediaObject!)

        exp.fulfill()
      },
      onError: { error in
        print("Received error:", error)
      })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetContainer() throws {
    let exp = expectation(description: "Gets container")

    _ = subject.getArchive(channelId: 5).subscribe(
      onNext: { result in
        var container: EtvnetAPI.Media? = nil

        for item in result!.media {
          let type = item.mediaType

          if type == .container {
            container = item
            break
          }
        }

        print(container!)

        exp.fulfill()
      },
      onError: { error in
        print("Received error:", error)
      })

    waitForExpectations(timeout: 10, handler: nil)
  }

  func testGetAllBookmarks() throws {
    let data = subject.getBookmarks()!

    XCTAssertNotNil(data)
    XCTAssert(data.bookmarks.count > 0)
    XCTAssert(data.pagination.count > 0)
  }

//  func testGetFolders() throws {
//    let result = subject.getFolders()
//
//    //print(result as Any)
//
//    XCTAssertEqual(result["status_code"], 200)
////        XCTAssert(result["data"].count > 0)
//  }

  func testGetBookmark() throws {
    let bookmarks = subject.getBookmarks()!.bookmarks

    let bookmarkDetails = subject.getBookmark(id: bookmarks[0].id)

    XCTAssertNotNil(bookmarkDetails)
  }

  func testAddBookmark() throws {
    let id = 760894

    let result = subject.addBookmark(id: id)

    XCTAssertTrue(result)
  }

  func testRemoveBookmark() throws {
    let id = 760894

    let result = subject.removeBookmark(id: id)

    XCTAssertTrue(result)
  }

  func testGetTopicItems() throws {
    for topic in EtvnetAPI.Topics {
      let data = subject.getTopicItems(topic)!

      XCTAssertNotNil(data)
      XCTAssert(data.media.count > 0)
      XCTAssert(data.pagination.count > 0)
    }
  }

  func testGetVideoResolution() {
    //    puts subject.bfuncrate_to_resolution(1500)
  }

  func testGetAllLiveChannels() throws {
    let list = subject.getLiveChannels()

    print(list)
    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetLiveChannelsByCategory() throws {
    let list = subject.getLiveChannelsByCategory(category: 7)

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetLiveFavoriteChannels() throws {
    let list = subject.getLiveChannels(favoriteOnly: true)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testAddFavoriteChannel() {
    let id = 46

    let _ = subject.addFavoriteChannel(id: id)

    //print(result as Any)
  }

  func testRemoveFavoriteChannel() {
    let id = 46

    let _ = subject.removeFavoriteChannel(id: id)

    //print(result as Any)
  }

  func testGetLiveSchedule() throws {
    let list = subject.getLiveSchedule(liveChannelId: "423")

    print(String(decoding: list, as: UTF8.self))

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetLiveCategories() throws {
    let list = subject.getLiveCategories()

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetHistory() throws {
    let data = subject.getHistory()!

    XCTAssertNotNil(data)
    XCTAssert(data.media.count > 0)
    XCTAssert(data.pagination.count > 0)
  }

  func testGetChildren() throws {
    let data = subject.getChildren(488406)!

    XCTAssertNotNil(data)
    XCTAssert(data.children.count > 0)
    XCTAssert(data.pagination.count > 0)
  }

}
