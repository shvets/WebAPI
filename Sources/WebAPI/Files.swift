import Foundation

open class Files {
  private static let DefaultFileManager = FileManager.default

  open class func exist(_ path: String) -> Bool {
    return DefaultFileManager.fileExists(atPath: path)
  }

  open class func readFile(_ path: String) -> Data? {
    var data: Data?

    if DefaultFileManager.fileExists(atPath: path) {
      if let file = FileHandle(forReadingAtPath: path) {
        data = file.readDataToEndOfFile()

        file.closeFile()
      }
    }

    return data
  }

  open class func createFile(_ path: String, data: Data?=nil) -> Bool {
    if !DefaultFileManager.fileExists(atPath: path) {
      DefaultFileManager.createFile(atPath: path, contents: data)

      return true
    }
    else {
      if let file = FileHandle(forWritingAtPath: path) {
        file.truncateFile(atOffset: 0)
        file.write(data!)

        file.closeFile()

        return true
      }
      else {
        return false
      }
    }
  }

  open class func updateFile(_ path: String, data: Data) -> Bool {
    if DefaultFileManager.fileExists(atPath: path) {
      if let file = FileHandle(forWritingAtPath: path) {
        file.truncateFile(atOffset: 0)

        file.write(data)

        file.closeFile()

        return true
      }
      else {
        return false
      }
    }
    else {
      return false
    }
  }

  open class func removeFile(_ path: String) throws {
    if DefaultFileManager.fileExists(atPath: path) {
      try DefaultFileManager.removeItem(atPath: path)
    }
  }

  //let fileName = NSURL(fileURLWithPath: configName).lastPathComponent!
  //let path = NSURL(fileURLWithPath: configName).path!

//  do {
//      try defaultManager.createDirectory(atPath: configName, withIntermediateDirectories: true)
//  }
//  catch {
//       print("Error creating directory")
//  }
}
