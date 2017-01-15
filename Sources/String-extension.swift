extension String {
  public func find(_ sub: String) -> String.Index? {
    return self.range(of: sub)?.lowerBound
  }

  public func trim() -> String {
    return self.trimmingCharacters(in: .whitespaces)
  }

}
