extension String {
  func find(_ sub: String) -> String.Index? {
    return self.range(of: sub)?.lowerBound
  }

  func trim() -> String {
    return self.trimmingCharacters(in: .whitespaces)
  }

}
