import XCTest
import SwiftyJSON

@testable import WebAPI

class EtvnetAPITests: XCTestCase {
  static var config = Config(configName: "etvnet.config")
  var subject = EtvnetAPI(config: config)

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.

    if !subject.checkToken() {
      let result = subject.authorization()

      if result.user_code != "" {
        _ = subject.tryCreateToken(user_code: result.user_code, device_code: result.device_code, activation_url: result.activation_url)
      }
    }
  }

  func testGetChannels() {
    let result = subject.getChannels()

    //print(result)

    XCTAssertEqual(result["status_code"], 200)
    XCTAssertNotNil(result["data"])
  }

  func testGetArchive() {
    let result = subject.getArchive(channel_id: 3)

    //print(result)
    //print(result["data"]["media"])

    XCTAssertEqual(result["status_code"], 200)
    XCTAssert(result["data"]["media"].count > 0)
  }

  func testGetGenres() {
    let result = subject.getGenres()

    //print(result)

    XCTAssertEqual(result["status_code"], 200)
    XCTAssert(result["data"].count > 0)
  }

  func testGetBlockbusters() {
    let result = subject.getBlockbusters()

    print(result)

    XCTAssertEqual(result["status_code"], 200)
    XCTAssert(result["data"]["media"].count > 0)
  }

  func testSearch() {
    let query = "news"
    let result = subject.search(query: query)

//        print(result)

    XCTAssertEqual(result["status_code"], 200)
    XCTAssert(result["data"]["media"].count > 0)
  }

  func testPagination() {
    let query = "news"

    let result1 = subject.search(query: query, per_page: 20, page: 1)

//        print(result1)

    let pagination1 = result1["data"]["pagination"]

//        print(pagination1["has_next"])

    XCTAssertEqual(pagination1["has_next"], true)
    XCTAssertEqual(pagination1["has_previous"], false)
    XCTAssertEqual(pagination1["page"], 1)

    let result2 = subject.search(query: query, per_page: 20, page: 2)

    //    #print(result2)

    let pagination2 = result2["data"]["pagination"]


    XCTAssertEqual(pagination2["has_next"], true)
    XCTAssertEqual(pagination2["has_previous"], true)
    XCTAssertEqual(pagination2["page"], 2)
  }

  func testGetNewArrivals() {
    let result = subject.getNewArrivals()

    //print(result)

//        expect(result["status_code"]).to be 200
//        expect(result["data"].size > 0).to be true

    XCTAssertEqual(result["status_code"], 200)
    XCTAssert(result["data"]["media"].count > 0)
  }

  func testGetUrl() {
    let id = 760894 // 329678
    let  bitrate = "1200"
    let format = "mp4"

    let url_data = subject.getUrl(id, format: format, mediaProtocol: "hls", bitrate: bitrate)

    puts("Media Url: " + url_data["url"]!)

    //    #print("Play list:\n" + self.service.get_play_list(url_data["url"]))
  }

  func testGetLiveChannelUrl() {
    let id = 117
    let  bitrate = "800"
    let format = "mp4"

    let url_data = subject.getLiveChannelUrl(id, format: format, bitrate: bitrate)

    puts("Media Url: " + url_data["url"]!)

    //    #print("Play list:\n" + self.service.get_play_list(url_data["url"]))
  }

  func testGetMediaObjects() {
    let result = subject.getArchive(channel_id: 3)

    //print(result)

    var media_object: JSON? = nil

    for (_, item) in result["data"]["media"] {
      let type = item["type"]

      if type == "MediaObject" {
        media_object = item
        break
      }
    }

    print(media_object as Any)
  }

  func testGetContainer() {
    let result = subject.getArchive(channel_id: 5)

    print(result)

    var container: JSON? = nil

    for (_, item) in result["data"]["media"] {
      let type = item["type"]

      if type == "Container" {
        container = item
        break
      }
    }

    print(container as Any)
  }

  func testGetBookmarks() {
    let result = subject.getBookmarks()

    //print(result)

    XCTAssertEqual(result["status_code"], 200)
    XCTAssert(result["data"].count > 0)
  }

  func testGetFolders() {
    let result = subject.getFolders()

    //print(result)

    XCTAssertEqual(result["status_code"], 200)
//        XCTAssert(result["data"].count > 0)
  }

  func testGetBookmark() {
    let bookmarks = subject.getBookmarks()

    let bookmark = bookmarks["data"]["bookmarks"][0]

    let result = subject.getBookmark(id: bookmark["id"].rawString()!)

    //print(result)

    XCTAssertEqual(result["status_code"], 200)
    XCTAssert(result["data"].count > 0)
  }

  func testAddBookmark() {
     let id = 760894
    
    let result = subject.addBookmark(id: id)
    
    //print(result)

    XCTAssertEqual(result["status"], "Created")
  }
  
  func testRemoveBookmark() {
    let id = 760894
        
    let result = subject.removeBookmark(id: id)
    
    //print(result)

    XCTAssertEqual(result == JSON.null, true)
  }
  
  func testGetTopics() {
    for topic in EtvnetAPI.TOPICS {
      //print(topic)
      let result = subject.getTopicItems(topic)

      //print(result)

      XCTAssertEqual(result["status_code"], 200)
      XCTAssert(result["data"].count > 0)
    }
  }

  func testGetVideoResolution() {
    //    puts subject.bfuncrate_to_resolution(1500)
  }

  func testGetAllLiveChannels() {
    let result = subject.getLiveChannels(category: 0)

    //print(result)

    XCTAssertEqual(result["status_code"], 200)
    XCTAssert(result["data"].count > 0)
  }

  func testGetLiveChannelsByCategory() {
    let result = subject.getLiveChannels(category: 7)

    print(result)

    XCTAssertEqual(result["status_code"], 200)
    XCTAssert(result["data"].count > 0)
  }

  func testGetLiveFavoriteChannels() {
    let result = subject.getLiveChannels(favorite_only: true)

    print(result)

    XCTAssertEqual(result["status_code"], 200)
    XCTAssert(result["data"].count > 0)
  }

  func testAddFavoriteChannel() {
    let id = 46

    let result = subject.addFavoriteChannel(id: id)

    //print(result)

    XCTAssertEqual(result == JSON.null, true)
  }

  func testRemoveFavoriteChannel() {
    let id = 46

    let result = subject.removeFavoriteChannel(id: id)

    //print(result)

    XCTAssertEqual(result == JSON.null, true)
  }

  func testGetLiveCategories() {
    let result = subject.getLiveCategories()

    print(result)

    XCTAssertEqual(result["status_code"], 200)
    XCTAssert(result["data"].count > 0)
  }

}
