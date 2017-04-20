//import Unbox

public struct Track {
  public let id: String
  public let name: String

  public init(id: String, name: String) {
    self.id = id
    self.name = name
  }

//  public init(unboxer: Unboxer) throws {
//    self.id = try unboxer.unbox(key: "id")
//    self.name = try unboxer.unbox(key: "name")
//  }
}