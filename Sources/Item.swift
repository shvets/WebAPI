import Foundation

public class Item: Equatable {
  var key: String?
  var value: Any?

//class StorageItem: NSObject, NSCoding {
//  var id: String?
//  var properties: [Any]

//  required convenience init?(coder aDecoder: NSCoder) {
//    self.init()
//
//    self.id = aDecoder.decodeObject(forKey: "id") as? String
//  }
//
//  convenience init(_ id: String) {
//    self.init()
//
//    self.id = id
//  }
//
//  public func encode(with aCoder: NSCoder) {
//    if let id = id {
//      aCoder.encode(id, forKey: "id")
//    }
//  }

//    init(_ id: String, properties: [Any] = []) {
//      self.id = id
//      self.properties = properties
//    }
//
//  public static func ==(lhs: StorageItem, rhs: StorageItem) -> Bool {
//    return lhs.id == rhs.id
//  }

  init(key: String, value: Any) {
    self.key = key
    self.value = value
  }

  public static func ==(lhs: Item, rhs: Item) -> Bool {
    return lhs.key == rhs.key
  }
}
