import Foundation

open class FileStorage: Storage {
  var fileName: String

  public init(_ fileName: String) {
    self.fileName = fileName
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

}
