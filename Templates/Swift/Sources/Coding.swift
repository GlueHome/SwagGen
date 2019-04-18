{% include "Includes/Header.stencil" %}

import Foundation

{% if options.modelProtocol %}
public protocol {{ options.modelProtocol }}: Codable, Equatable { }
{% endif %}

{% for type, typealias in options.typeAliases %}
public typealias {{ type }} = {{ typealias }}
{% endfor %}

public protocol ResponseDecoder {

    func decode<T: Decodable>(_ type: T.Type, from: Data) throws -> T
}

extension JSONDecoder: ResponseDecoder {}

struct StringCodingKey: CodingKey, ExpressibleByStringLiteral {

    private let string: String
    private let int: Int?

    var stringValue: String { return string }

    init(string: String) {
        self.string = string
        int = nil
    }
    init?(stringValue: String) {
        string = stringValue
        int = nil
    }

    var intValue: Int? { return int }
    init?(intValue: Int) {
        string = String(describing: intValue)
        int = intValue
    }

    init(stringLiteral value: String) {
        string = value
        int = nil
    }
}

// Date structs for date and date-time formats

extension DateFormatter {

    convenience init(formatString: String, locale: Locale? = nil, timeZone: TimeZone? = nil) {
        self.init()
        dateFormat = formatString
        if let locale = locale {
            self.locale = locale
        }
        if let timeZone = timeZone {
            self.timeZone = timeZone
        }
    }

    convenience init(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) {
        self.init()
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
    }
}

let dateDecoder: (Decoder) throws -> Date = { decoder in
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        let formatterWithMilliseconds = DateFormatter()
        formatterWithMilliseconds.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatterWithMilliseconds.locale = Locale(identifier: "en_US_POSIX")
        formatterWithMilliseconds.timeZone = TimeZone(identifier: "UTC")

        let formatterWithoutMilliseconds = DateFormatter()
        formatterWithoutMilliseconds.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatterWithoutMilliseconds.locale = Locale(identifier: "en_US_POSIX")
        formatterWithoutMilliseconds.timeZone = TimeZone(identifier: "UTC")

        guard let date = formatterWithMilliseconds.date(from: string) ??
            formatterWithoutMilliseconds.date(from: string) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Could not decode date")
        }
        return date
    }

public struct DateDay: Codable, Comparable {

    /// The date formatter used for encoding and decoding
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = .current
        return formatter
    }()

    public let date: Date
    public let year: Int
    public let month: Int
    public let day: Int

    public init(date: Date = Date()) {
        self.date = date
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        guard let year = dateComponents.year,
            let month = dateComponents.month,
            let day = dateComponents.day else {
                fatalError("Date does not contain correct components")
        }
        self.year = year
        self.month = month
        self.day = day
    }

    public init(year: Int, month: Int, day: Int) {
        let dateComponents = DateComponents(calendar: .current, year: year, month: month, day: day)
        guard let date = dateComponents.date else {
            fatalError("Could not create date in current calendar")
        }
        self.date = date
        self.year = year
        self.month = month
        self.day = day
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let date = DateDay.dateFormatter.date(from: string) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date not in correct format of \(DateDay.dateFormatter.dateFormat ?? "")")
        }
        self.init(date: date)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let string = DateDay.dateFormatter.string(from: date)
        try container.encode(string)
    }

    public static func == (lhs: DateDay, rhs: DateDay) -> Bool {
        return lhs.year == rhs.year &&
            lhs.month == rhs.month &&
            lhs.day == rhs.day
    }

    public static func < (lhs: DateDay, rhs: DateDay) -> Bool {
        return lhs.date < rhs.date
    }
}

extension DateFormatter {

    public func string(from dateDay: DateDay) -> String {
        return string(from: dateDay.date)
    }
}

// for parameter encoding

extension DateDay {
    func encode() -> Any {
        return DateDay.dateFormatter.string(from: date)
    }
}

extension Date {
    func encode() -> Any {
        return {{ options.name }}.dateEncodingFormatter.string(from: self)
    }
}

extension URL {
    func encode() -> Any {
        return absoluteString
    }
}

extension RawRepresentable {
    func encode() -> Any {
        return rawValue
    }
}

extension Array where Element: RawRepresentable {
    func encode() -> [Any] {
        return map { $0.rawValue }
    }
}

extension Dictionary where Key == String, Value: RawRepresentable {
    func encode() -> [String: Any] {
        return mapValues { $0.rawValue }
    }
}

extension UUID {
    func encode() -> Any {
        return uuidString
    }
}

extension String {
    func encode() -> Any {
        return self
    }
}

extension Data {

    func encode() -> Any {
        return self
    }
}
