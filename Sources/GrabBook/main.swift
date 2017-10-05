import Foundation

import WebAPI

//let path = "http://audioknigi.club/alekseev-gleb-povesti-i-rasskazy"

if CommandLine.argc < 2 {
  print("No arguments are passed.")
  //let firstArgument = CommandLine.arguments[0]
  //print(firstArgument)
}
else {
  //print("Arguments are passed.")
  //let arguments = CommandLine.arguments
//  for argument in arguments {
//    print(argument)
//  }

  let client = AudioKnigiAPI()

  let path = CommandLine.arguments[1]

  let _ = try client.downloadAudioTracks(path)
}

