import Foundation

open class Prettifier {

  public static func prettify(encode: @escaping (JSONEncoder) throws -> Data) throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    let data = try encode(encoder)

    return String(data: data, encoding: .utf8)!
  }

}
