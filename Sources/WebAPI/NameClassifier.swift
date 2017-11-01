import Foundation

open class NameClassifier {
  public struct Item: Codable {
    public let id: String
    public let name: String
  }

  public struct ItemsGroup: Codable {
    public let key: String
    public let value: [Item]
  }

  public func classify(items: [Item]) throws -> [(key: String, value: [Any])] {
    var groups = [String: [Item]]()

    for item in items {
      let name = item.name
      let id = item.id

      let index = name.characters.count < 3 ? name.index(name.startIndex, offsetBy: name.count) : name.index(name.startIndex, offsetBy: 3)
      let groupName = name[name.startIndex..<index].uppercased()

      if !groups.keys.contains(groupName) {
        let group: [Item] = []

        groups[groupName] = group
      }

      let newItem = NameClassifier.Item(id: id, name: name.isEmpty ? " " : name)

      groups[groupName]?.append(newItem)
    }

    let sortedGroups = groups.sorted { $0.key < $1.key }

    return mergeSmallGroups(sortedGroups)
  }

  public func classify2(items: [Item]) throws -> [ItemsGroup] {
    let result = try classify(items: items)

    var items: [ItemsGroup] = []

    for item in result {
      let newGroup = NameClassifier.ItemsGroup(key: item.key, value: item.value as! [Item])

      items.append(newGroup)
    }

    return items
  }

  func mergeSmallGroups(_ groups: [(key: String, value: [Item])]) -> [(key: String, value: [Any])] {
    // merge groups into bigger groups with size ~ 20 records

    var classifier: [[String]] = []

    var groupSize = 0

    classifier.append([])

    var index = 0

    for (groupName, group) in groups {
      let groupWeight = group.count
      groupSize += groupWeight

      if groupSize > 20 || startsWithDifferentLetter(classifier[index], name: groupName) {
        groupSize = 0
        classifier.append([])
        index = index + 1
      }

      classifier[index].append(groupName)
    }

    // flatten records from different group within same classification
    // assign new name in format firstName-lastName, e.g. ABC-AZZ

    var newGroups: [(key: String, value: [Any])] = []

    for groupNames in classifier {
      if !groupNames.isEmpty {
        let key = groupNames[0] + "-" + groupNames[groupNames.count - 1]

        var value: [Any] = []

        for groupName in groupNames {
          let group = groups.filter { $0.key == groupName }.first

          if let group = group {
            for item in group.value {
              value.append(item)
            }
          }
        }

        newGroups.append((key: key, value: value))
      }
    }

    return newGroups
  }

  func startsWithDifferentLetter(_ list: [String], name: String) -> Bool {
    var result = false

    for n in list {
      if name[name.startIndex] != n[name.startIndex] {
        result = true
        break
      }
    }

    return result
  }

}
