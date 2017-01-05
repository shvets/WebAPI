import Foundation
import SwiftyJSON

open class JsonConverter {
  
  public static func toItems(_ contents: Data) -> [String: Any] {
    var result: [String: Any] = [:]
    
    let json = JSON(data: contents)
    
    for (key, value) in json {
      result[key] = value.rawString()
    }
    
    return result
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

  public static func prettified(_ string: Any?) -> String {
    let text = JSON(string).rawString(options: .prettyPrinted)

    return text!.replacingOccurrences(of: "\\/", with: "/")
  }
}
