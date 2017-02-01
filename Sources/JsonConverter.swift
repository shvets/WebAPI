import Foundation
import SwiftyJSON

open class JsonConverter {
  
  public static func toItems(_ contents: Data) -> [String: Any] {
    var result = [String: Any]()
    
    let json = JSON(data: contents)
    
    for (key, value) in json {
      if value.type == .dictionary {
        result[key] = convertToDictionary(value)
      }
      else if value.type == .array {
        result[key] = convertToArray(value)
      }
      else {
        result[key] = value.rawString()
      }
    }
    
    return result
  }

  static func convertToDictionary(_ json: JSON) -> [String: Any] {
    var dict = [String: Any]()

    for (key, value) in json.dictionaryObject! {
      if value as? [String: Any] != nil {
        dict[key] = value as! [String: Any]
      }
      else if value as? [Any] != nil {
        dict[key] = value as! [Any]
      }
      else {
        dict[key] = (value as! String).description
      }
    }

    return dict
  }

  static func convertToArray(_ json: JSON) -> [Any] {
    var array = [Any]()

    for value in json.arrayObject! {
      if value as? [String: Any] != nil {
        array.append(value)
      }
      else if value as? [Any] != nil {
        array.append(value)
      }
      else {
        array.append((value as! String).description)
      }
    }

    return array
  }

  public static func toData(_ items: [String: Any]) -> Data {
    var content = Data()
    
    do {
      content = try JSONSerialization.data(withJSONObject: items, options: .prettyPrinted)
    }
    catch {
      print("Error")
    }
    
    return content
  }

  public static func prettified(_ items: [String: Any]) -> String {
    let text = String(data: toData(items), encoding: String.Encoding.utf8)!

    return text.replacingOccurrences(of: "\\/", with: "/")
  }

  public static func prettified(_ json: JSON) -> String {
    let text = json.rawString(options: .prettyPrinted)

    return text!.replacingOccurrences(of: "\\/", with: "/")
  }

  public static func prettified(_ any: Any?) -> String {
    let text = JSON(any!).rawString(options: .prettyPrinted)

    return text!.replacingOccurrences(of: "\\/", with: "/")
  }
}
