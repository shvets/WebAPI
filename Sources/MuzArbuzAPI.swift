import Foundation

open class MuzArbuzAPI: HttpService {
  static let SiteUrl = "https://muzarbuz.com"
  static let ApiUrl = "\(SiteUrl)/api/v1"
  let UserAgent = "MuzArbuz User Agent"


  let ValidParameters = ["album", "artists", "collection__id", "parent__id", "genre__in"]

  let CyrillicLetters = ["А", "Б", "В", "Г", "Д", "Е", "Ё", "Ж", "З", "И", "Й", "К", "Л", "М", "Н", "О", "П", "Р", "С",
      "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш", "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", "Я"]

  let LatinLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
    "T", "U", "V", "W", "X", "Y", "Z"]

}
