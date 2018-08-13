import Foundation

protocol AnyEncoder {
  func encode<T: Encodable>(_ value: T) throws -> Data
}

extension JSONEncoder: AnyEncoder {}

extension Encodable {
  func encoded(using encoder: AnyEncoder = JSONEncoder()) throws -> Data {
    if let encoder = encoder as? JSONEncoder {
      encoder.outputFormatting = .prettyPrinted
    }

    return try encoder.encode(self)
  }

  func prettify() throws -> String {
    return String(data: try encoded(), encoding: .utf8)!
  }
}

protocol AnyDecoder {
  func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: AnyDecoder {}

extension Data {
  func decoded<T: Decodable>(using decoder: AnyDecoder = JSONDecoder()) throws -> T {
    return try decoder.decode(T.self, from: self)
  }
}

extension KeyedDecodingContainerProtocol {
  func decode<T: Decodable>(forKey key: Key) throws -> T {
    return try decode(T.self, forKey: key)
  }

  func decode<T: Decodable>(forKey key: Key, default defaultExpression: @autoclosure () -> T) throws -> T {
    return try decodeIfPresent(T.self, forKey: key) ?? defaultExpression()
  }
}


