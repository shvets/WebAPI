import Foundation

extension KinoGoAPI {
  public struct Episode: Codable {
    public let title: String
    public let file: String

    public var files: [String] {
      get {
        return file.replacingOccurrences(of: "or", with: ",")
          .split(separator: ",").map {String($0).trim().replacingOccurrences(of: " ", with: "")}
      }
    }

    public var name: String {
      get {
        let pattern = "(<br/><i>.*</i>)"

        do {
          let regex = try NSRegularExpression(pattern: pattern)

          return regex.stringByReplacingMatches(in: self.title, options: [], range: NSMakeRange(0, self.title.count), withTemplate: "")
        }
        catch {
          return self.title
        }
      }
    }

//    enum CodingKeys: String, CodingKey {
//      case title
//      case file
//    }
  }

  public struct File: Codable {
    public let comment: String
    public let file: String

    public func urls() -> [String] {
      return file.split(separator: ",").map {
        let text = String($0).trim()
        let index1 = text.find("or")

        let startIndex = text.index(text.startIndex, offsetBy: 6)

        let endIndex: String.Index

        if index1 != nil {
          endIndex = index1!
        }
        else {
          endIndex = text.endIndex
        }

        return String(text[startIndex ..< endIndex]).trim()
      }.reversed()
    }

    public var name: String {
      get {
        let pattern = "(<br/><i>.*</i>)"

        do {
          let regex = try NSRegularExpression(pattern: pattern)

          return regex.stringByReplacingMatches(in: self.comment, options: [], range: NSMakeRange(0, self.comment.count), withTemplate: "")
        }
        catch {
          return self.comment
        }
      }
    }
  }

  public struct Season: Codable {
    public let comment: String
    public let folder: [File]

    public var name: String {
      get {
        return comment.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
      }
    }
  }

}