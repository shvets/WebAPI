import XCTest
import SwiftyJSON
import SwiftSoup

@testable import WebAPI

class GidOnlineAPITests: XCTestCase {
  var subject = GidOnlineAPI()

  var document: Document?

  var allMovies: [Any]?

  override func setUp() {
    super.setUp()

    do {
      document = try subject.fetchDocument(GidOnlineAPI.URL)
    }
    catch {
      print("Error fetching document")
    }
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testGetGenres() throws {
    let result = try subject.getGenres(document!)

    print(JsonConverter.prettified(result))
  }

  func testGetTopLinks() throws {
    let result = try subject.getTopLinks(document!)

    print(JsonConverter.prettified(result))
  }

  func testGetActors() throws {
    //let document = try subject.fetchDocument(GidOnlineAPI.URL)

    let result = try subject.getActors(document!)

    print(JsonConverter.prettified(result))
  }

  func testGetActorsByLetter() throws {
    let result = try subject.getActors(document!, letter: "А")

    print(JsonConverter.prettified(result))
  }

  func testGetDirectors() throws {
    let result = try subject.getDirectors(document!)

    print(JsonConverter.prettified(result))
  }

  func testGetDirectorsByLetter() throws {
    let result = try subject.getDirectors(document!, letter: "В")

    print(JsonConverter.prettified(result))
  }

  func testGetCountries() throws {
    let result = try subject.getCountries(document!)

    print(JsonConverter.prettified(result))
  }

  func testGetYears() throws {
    let result = try subject.getYears(document!)

    print(JsonConverter.prettified(result))
  }

  func testGetSeasons() throws {
    let result = try subject.getSeasons("/2016/03/strazhi-galaktiki/")

    print(JsonConverter.prettified(result))
  }

  func testGetEpisodes() throws {
    let result = try subject.getEpisodes("/2016/03/strazhi-galaktiki")

    print(JsonConverter.prettified(result))
  }

  func testGetAllMovies() throws {
    let allMovies = try subject.getMovies(document!)

    print(JsonConverter.prettified(allMovies))
  }

  func testGetMoviesByGenre() throws {
    let document = try subject.fetchDocument(GidOnlineAPI.URL + "/genre/vestern/")

    let result = try subject.getMovies(document!, path: "/genre/vestern/")

    print(JsonConverter.prettified(result))
  }

  func testGetMovieUrl() throws {
    let movieUrl = "http://gidonline.club/2017/01/pravila-sema-teoriya-babnika/"

    let urls = try subject.retrieveUrls(movieUrl)

    print(JsonConverter.prettified(urls))
  }

//it 'gets movie url' do
//#movie_url = all_movies[1][:path]
//#
//# print(movie_url)
//
//movie_url = 'http://gidonline.club/2016/07/pomnish-menya/'
//
//urls = subject.retrieve_urls(movie_url)
//
//ap urls
//end
//
//it 'gets serials url' do
//movie_url = 'http://gidonline.club/2016/03/strazhi-galaktiki/'
//
//document = subject.get_movie_document(movie_url)
//
//serial_info = subject.get_serial_info(document)
//
//ap serial_info
//end
//
//it 'gets playlist' do
//movie_url = all_movies[1][:path]
//
//puts movie_url
//
//urls = subject.retrieve_urls(movie_url)
//
//ap urls
//
//play_list = subject.get_play_list(urls[2][:url])
//
//puts play_list
//end
//
//it 'gets media data' do
//movie_url = all_movies[0][:path]
//
//document = subject.fetch_document(url: movie_url)
//
//data = subject.get_media_data(document)
//
//ap data
//end
//
//it 'gets serials info' do
//movie_url = 'http://gidonline.club/2016/03/strazhi-galaktiki/'
//
//document = subject.get_movie_document(movie_url)
//
//serial_info = subject.get_serial_info(document)
//
//ap serial_info
//
//serial_info['seasons'].keys.each do |number|
//print(number)
//print(serial_info['seasons'][number])
//end
//end
//
//it "checks if media is serial" do
//url = "http://gidonline.club/2016/07/priklyucheniya-vudi-i-ego-druzej/"
//
//result = subject.is_serial(url)
//
//ap result
//end
//
//it 'searches' do
//query = 'вуди'
//
//result = subject.search(query)
//
//ap result
//end
//
//it 'searches actors' do
//query = 'Аллен'
//
//result = subject.search_actors(document, query)
//
//ap result
//end
//
//it 'searches directors' do
//query = 'Люк'
//
//result = subject.search_directors(document, query)
//
//ap result
//end

}
