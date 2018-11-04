import Foundation

extension String {
  public func find(_ sub: String) -> String.Index? {
    return self.range(of: sub)?.lowerBound
  }


  public func findR(_ sub: String) throws -> String.Index? {
    var index: String.Index?

    let regex = try NSRegularExpression(pattern: sub)

    let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))

    //var matched: String?

    let match = matches.first

    if let match = match, 0 < match.numberOfRanges {
      let capturedGroupIndex = match.range(at: 0)

      index = self.index(self.startIndex, offsetBy: capturedGroupIndex.location)
      //let index2 = self.index(index1, offsetBy: capturedGroupIndex.length-1)

      //matched = String(link[index1 ... index2])
    }

    return index
  }

  public func trim() -> String {
    return self.trimmingCharacters(in: .whitespaces)
  }

  func addingPercentEncoding(withAllowedCharacters characterSet: CharacterSet, using encoding: String.Encoding) -> String {
    let stringData = self.data(using: encoding, allowLossyConversion: true) ?? Data()

    let percentEscaped = stringData.map {byte->String in
      if characterSet.contains(UnicodeScalar(byte)) {
        return String(UnicodeScalar(byte))
      }
      else if byte == UInt8(ascii: " ") {
        return "+"
      }
      else {
        return String(format: "%%%02X", byte)
      }
    }.joined()

    return percentEscaped
  }

  func windowsCyrillicPercentEscapes() -> String {
    let rfc3986Unreserved = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")

    let encoding = CFStringEncoding(CFStringEncodings.windowsCyrillic.rawValue)

    let windowsCyrillic = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(encoding))

    return self.addingPercentEncoding(withAllowedCharacters: rfc3986Unreserved,  using: windowsCyrillic)
  }
}
