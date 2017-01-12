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

  public func remove(_ key: String) -> Bool {
    return items.removeValue(forKey: key) != nil
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
