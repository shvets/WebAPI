import Foundation
import WebAPI

class GrabBook {
  let downloadManager = DownloadManager()

  func parseCommandLine() -> Bool {
    return CommandLine.argc > 1
  }

  func grabAudioKnigi(_ url: String) throws {
    try downloadManager.download(clientType: .audioKnigi, url: url)
  }

  func grabAudioBoo(_ url: String) throws {
    try downloadManager.download(clientType: .audioBoo, url: url)
  }

  func grabBookZvook(_ url: String) throws {
    try downloadManager.download(clientType: .bookZvook, url: url)
  }
}

let grabber = GrabBook()

if grabber.parseCommandLine() {
  if CommandLine.arguments[1] == "--boo" {
    let url = CommandLine.arguments[2]

    try grabber.grabAudioBoo(url)
  }
  else if CommandLine.arguments[1] == "--zvook" {
    let url = CommandLine.arguments[2]

    try grabber.grabBookZvook(url)
  }
  else {
    let url = CommandLine.arguments[1]

    try grabber.grabAudioKnigi(url)
  }
}
else {
  print("No arguments are passed.")
}
