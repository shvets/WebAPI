import Foundation

open class Prettifier {
  static var encoder: JSONEncoder = {
    let encoder = JSONEncoder()

    encoder.outputFormatting = .prettyPrinted

    return encoder
  }()

  public static func prettify(encode: @escaping (JSONEncoder) throws -> Data) throws -> String {
    let data = try encode(encoder)

    return String(data: data, encoding: .utf8)!
  }

  public static func asPrettifiedData(_ value: Any) throws -> Data {
    if let value = value as? [[String: String]] {
      return try encoder.encode(value)
    }
    else if let value = value as? [String: String] {
      return try encoder.encode(value)
    }

    return Data()
  }

}
