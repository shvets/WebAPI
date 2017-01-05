import Foundation

open class FileStorage: Storage {
  var fileName: String

  public init(_ fileName: String) {
    self.fileName = fileName
  }

  override public func exist() -> Bool {
    return FileManager.default.fileExists(atPath: fileName)
  }

  override public func loadStorage() -> [String: Any] {
    var contents: Data?

    if FileManager.default.fileExists(atPath: fileName) {
      if let file = FileHandle(forReadingAtPath: fileName) {
        contents = file.readDataToEndOfFile()

        file.closeFile()
      }
    }
    else {
      print("File does not exist")
      contents = Data()
    }

    return JsonConverter.toItems(contents!)
  }

  override public func saveStorage(_ items: [String: Any]) {
    let contents: Data = JsonConverter.toData(items)

    let defaultManager = FileManager.default

    if !defaultManager.fileExists(atPath: fileName) {
      defaultManager.createFile(atPath: fileName, contents: contents)
    }
    else {
      if let file = FileHandle(forWritingAtPath: fileName) {
        file.truncateFile(atOffset: 0)
        file.write(contents)

        file.closeFile()
      }
      else {
        print("Error writing to file")
      }
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

  public static func createFile(_ fileName: String, data: Data?=nil) -> Bool {
    let fileManager = FileManager.default

    if !fileManager.fileExists(atPath: fileName) {
      fileManager.createFile(atPath: fileName, contents: data)

      return true
    }
    else {
      return false
    }
  }

  public static func updateFile(_ fileName: String, data: Data) -> Bool {
    let fileManager = FileManager.default

    if fileManager.fileExists(atPath: fileName) {
      if let file = FileHandle(forWritingAtPath: fileName) {
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

  public static func removeFile(_ fileName: String) throws {
    let fileManager = FileManager.default

    if fileManager.fileExists(atPath: fileName) {
      try fileManager.removeItem(atPath: fileName)
    }
  }

  public static func readFile(_ fileName: String) -> Data? {
    var content: Data?

    if FileManager.default.fileExists(atPath: fileName) {
      if let file = FileHandle(forReadingAtPath: fileName) {
        content = file.readDataToEndOfFile()

        file.closeFile()
      }
    }
    else {
      print("File does not exist")
    }

    return content
  }

}
