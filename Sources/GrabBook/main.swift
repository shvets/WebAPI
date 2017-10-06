import Foundation

import WebAPI

class GrabBook {

  func parseCommandLine() -> Bool {
    return CommandLine.argc > 1
  }

  func grab() throws {
    let client = AudioKnigiAPI()

    let path = CommandLine.arguments[1]

    try client.downloadAudioTracks(path)
  }

  func grab2() throws {
    let client = AudioBooAPI()

    let path = CommandLine.arguments[1]

    let encodedPath = path.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    print(path)

    let playlistUrls = try client.getPlaylistUrls(encodedPath)

    print(playlistUrls)

    let _ = try client.getAudioTracks(playlistUrls[0])
  }

}

//let path = "http://audioknigi.club/alekseev-gleb-povesti-i-rasskazy"

let grabber = GrabBook()

if grabber.parseCommandLine() {
  try grabber.grab()
}
else {
  print("No arguments are passed.")
}
