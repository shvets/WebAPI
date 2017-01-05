import Foundation

open class Storage {
  public var items: [String: Any] = [:]

  public func clear() {
    items.removeAll()
  }

  public func exist() -> Bool {
    return true
  }

  public func add(key: String, value: Any) {
    items[key] = value
  }

  func remove(_ key: String) {
    items.removeValue(forKey: key)
  }

  public func load() {
    clear()
    
    if exist() {
      items = loadStorage()
    }
  }

  public func save(_ items: [String: Any]?=nil) {
    if let localItems = items {
      self.items = localItems
    }

    saveStorage(self.items)
  }

  func loadStorage() -> [String: Any] {
    return [:]
  }
  
  func saveStorage(_ items: [String: Any]) {}
  
}
