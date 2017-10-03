import Foundation

open class Config {
  var fileName: String

  public var items: [String: String] = [:]

  let encoder = JSONEncoder()
  let decoder = JSONDecoder()

  public init(configName fileName: String) {
    self.fileName = fileName
  }

  public func clear() {
    items.removeAll()
  }

  public func add(key: String, value: String) {
    items[key] = value
  }

  public func remove(_ key: String) -> Bool {
    return items.removeValue(forKey: key) != nil
  }

  public func load() {
    clear()

    do {
      items = try loadStorage()
    }
    catch let e {
      print("Error: \(e)")
    }
  }

  public func save() {
    do {
      try saveStorage(self.items)
    }
   catch let e {
      print("Error: \(e)")
    }
  }

  public func exist() -> Bool {
    return Files.exist(fileName)
  }

  public func loadStorage() throws -> [String: String] {
    if let data = Files.readFile(fileName) {
      return try decoder.decode([String: String].self, from: data)
    }
    else {
      //print("File does not exist")

      return [:]
    }
  }

  public func saveStorage(_ items: [String: String]) throws {
    let data = try encoder.encode(items)

    if !Files.createFile(fileName, data: data) {
      print("Error writing to file")
    }
  }
}
