public enum WatchStatus: Int {
  case new = 0
  case partiallyWatched
  case finished
}

extension WatchStatus: RawRepresentable {
  public typealias RawValue = Int

  public init?(rawValue: RawValue) {
    switch rawValue {
      case 0: self = .new
      case 1: self = .partiallyWatched
      case 2: self = .finished
      default: self = .new
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .new: return 0
      case .partiallyWatched: return 1
      case .finished: return 2
    }
  }

  public var description : String {
    switch self {
      case .new: return "New";
      case .partiallyWatched: return "Partially Watched";
      case .finished: return "Finished";
    }
  }
}
