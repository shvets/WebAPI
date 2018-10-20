import Foundation

extension KinoGoAPI {
  public struct Episode: Codable {
    public let comment: String
    public let file: String

    public var files: [String] {
      get {
        return file.split(separator: ",").map {String($0).trim().replacingOccurrences(of: " ", with: "") }
      }
    }

    enum CodingKeys: String, CodingKey {
      case comment
      case file
    }
  }

  public struct Season: Codable {
    public let comment: String
    public let playlist: [Episode]

    public var name: String {
      get {
        return comment.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
      }
    }
  }

}