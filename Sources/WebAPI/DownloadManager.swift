import Foundation
import Alamofire
import Files

open class DownloadManager {
  public enum ClienType {
    case audioKnigi
    case audioBoo
    case bookZvook
  }

  public init() {}

  public func download(clientType: ClienType, url: String) throws {
    switch clientType {
      case .audioKnigi:
        try downloadAudioKnigiTracks(url)
      case .audioBoo:
        try downloadAudioBooTracks(url)
      case .bookZvook:
        try downloadBookZvookTracks(url)
    }
  }

  public func downloadAudioKnigiTracks(_ url: String) throws {
    let client = AudioKnigiAPI()

    var audioTracks = [AudioKnigiAPI.Track]()
    
    let semaphore = DispatchSemaphore.init(value: 0)

    _ = try client.getAudioTracks(url).subscribe(
      onNext: { result in
        audioTracks = result

        semaphore.signal()
    })

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)

    let bookDir = URL(string: url)!.lastPathComponent

    var currentAlbum: String?

    for track in audioTracks {
      print(track)

      if !track.albumName.isEmpty {
        currentAlbum = track.albumName
      }

      let path = track.url
      let name = track.title

      let encodedPath = path.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

      download(name: "\(name).mp3", path: encodedPath, bookDir: currentAlbum == nil ? bookDir :  bookDir + currentAlbum!)
    }
  }

  public func downloadAudioBooTracks(_ url: String) throws {
    let client = AudioBooAPI()

    let playlistUrls = try client.getPlaylistUrls(url)

    if playlistUrls.count > 0 {
      let playlistUrl = playlistUrls[0]

      let audioTracks = try client.getAudioTracks(playlistUrl)
      var bookDir = URL(string: url)!.lastPathComponent
      bookDir = String(bookDir[...bookDir.index(bookDir.endIndex, offsetBy: -".html".count-1)])

      for track in audioTracks {
        print(track)

        let path = "\(AudioBooAPI.ArchiveUrl)\(track.sources[0].file)"
        let name = track.orig

        download(name: name, path: path, bookDir: bookDir)
      }
    }
    else {
      print("Cannot find playlist.")
    }
  }

  public func downloadBookZvookTracks(_ url: String) throws {
    let client = BookZvookAPI()

    let playlistUrls = try client.getPlaylistUrls(url)

    if playlistUrls.count > 0 {
      let playlistUrl = playlistUrls[0]

      let audioTracks = try client.getAudioTracks(playlistUrl)
      var bookDir = URL(string: url)!.lastPathComponent
      bookDir = String(bookDir[...bookDir.index(bookDir.endIndex, offsetBy: -".html".count-1)])

      for track in audioTracks {
        print(track)

        let path = "\(AudioBooAPI.ArchiveUrl)\(track.sources[0].file)"
        let name = track.orig

        download(name: name, path: path, bookDir: bookDir)
      }
    }
    else {
      print("Cannot find playlist.")
    }
  }

  func download(name: String, path: String, bookDir: String) {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    let fileURL = documentsURL.appendingPathComponent(bookDir).appendingPathComponent(name)

    downloadTrack(from: path, to: fileURL)
  }

  func downloadTrack(from: String, to: URL) {
    let utilityQueue = DispatchQueue.global(qos: .utility)

    let semaphore = DispatchSemaphore.init(value: 0)

    if File.exists(atPath: to.path) {
      print("\(to.path) --- exist")

      return
    }

    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
      return (to, [.removePreviousFile, .createIntermediateDirectories])
    }

    Alamofire.download(from, to: destination)
      .downloadProgress(queue: utilityQueue) { progress in
        //print("Download Progress: \(progress.fractionCompleted)")
      }
      .responseData(queue: utilityQueue) { response in
        if let url = response.destinationURL {
          FileManager.default.createFile(atPath: url.path, contents: response.result.value)
        }
        else {
          print("Cannot download \(to.path)")
        }

        semaphore.signal()
      }

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
  }
}
