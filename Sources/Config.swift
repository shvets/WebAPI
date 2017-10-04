protocol Config {
  associatedtype Item

  var items: [String: Item] { get set }

  func clear()

  func add(key: String, value: Item)

  func remove(_ key: String) -> Bool

  func load()

  func save()

  func exist() -> Bool
}
