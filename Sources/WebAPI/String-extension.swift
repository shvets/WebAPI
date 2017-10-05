import Foundation

extension String {
  public func find(_ sub: String) -> String.Index? {
    return self.range(of: sub)?.lowerBound
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
