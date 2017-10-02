import Foundation

open class FileStorage: Storage {
  var fileName: String

  let decoder = JSONDecoder()

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

    //return JsonConverter.toItems(contents!)

    var items = [String: String]()

    do {
      items = try decoder.decode([String: String].self, from: contents!)
    }
    catch {
    }

    return items
  }

  override public func saveStorage(_ items: [String: Any]) {
    var contents: Data = Data()

    do {
      let encoder = JSONEncoder()

      contents = try encoder.encode(items)
    }
    catch {
    }

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
