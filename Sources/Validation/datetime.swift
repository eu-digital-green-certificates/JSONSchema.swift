import Foundation

func validateDateTime(_ context: Context, _ value: Any) -> AnySequence<ValidationError> {
  if let date = value as? String {
    if let regularExpression = try? NSRegularExpression(pattern: "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}", options: .caseInsensitive) {
      let range = NSRange(location: 0, length: date.utf16.count)
      let result = regularExpression.matches(in: date, options: [], range: range)
      if result.isEmpty  {
        return AnySequence([
          ValidationError(
              "'\(date)' is not a valid RFC 3339 formatted date.",
            instanceLocation: context.instanceLocation,
            keywordLocation: context.keywordLocation
          )
        ])
      }
    }

    let rfc3339DateTimeFormatter = DateFormatter()

    /// Setting to a fixed locale because users can override the 12/24-hour format in the system settings, which causes DateFormatter to rewrite the format string
    /// https://developer.apple.com/library/archive/qa/qa1480/_index.html
    rfc3339DateTimeFormatter.locale = Locale(identifier: "en_US_POSIX")

    rfc3339DateTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    if rfc3339DateTimeFormatter.date(from: date) != nil {
      return AnySequence(EmptyCollection())
    }

    rfc3339DateTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    if rfc3339DateTimeFormatter.date(from: date) != nil {
      return AnySequence(EmptyCollection())
    }

    rfc3339DateTimeFormatter.dateFormat = "yyyy-MM-dd't'HH:mm:ss.SSS'z'"
    if rfc3339DateTimeFormatter.date(from: date) != nil {
      return AnySequence(EmptyCollection())
    }

    return AnySequence([
      ValidationError(
        "'\(date)' is not a valid RFC 3339 formatted date-time.",
        instanceLocation: context.instanceLocation,
        keywordLocation: context.keywordLocation
      )
    ])
  }

  return AnySequence(EmptyCollection())
}
