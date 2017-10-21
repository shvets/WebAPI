import Foundation
import Files

open class PlainConfig: Config {
  public typealias Item = String

  private var list: [String: Item] = [:]

  public var items: [String: Item] {
    get {
      return list
    }
    set {
      list = newValue
    }
  }

  var fileName: String = ""

  let encoder = JSONEncoder()
  let decoder = JSONDecoder()

  public init(_ fileName: String) {
    self.fileName = fileName
  }

  public func clear() {
    items.removeAll()
  }

  public func exist() -> Bool {
    return File.exists(atPath: fileName)
  }

  public func add(key: String, value: Item) {
    items[key] = value
  }

  public func remove(_ key: String) -> Bool {
    return items.removeValue(forKey: key) != nil
  }

  public func load() {
    clear()

    do {
      let data = try File(path: fileName).read()

      items = try decoder.decode([String: Item].self, from: data)
    }
    catch let e {
      print("Error: \(e)")
    }
  }

  public func save() {
    do {
      let data = try encoder.encode(items)

      try FileSystem().createFile(at: fileName, contents: data)
    }
    catch let e {
      print("Error: \(e)")
    }
  }

}
