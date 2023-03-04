import Foundation
import JJLISO8601DateFormatter

/// AnandaValueExtractor
///
/// Extract value from `AnandaJSON`
public protocol AnandaValueExtractor {
    /// Extract `Bool` from `AnandaJSON`
    func extractBool(from json: AnandaJSON) -> Bool?

    /// Extract `Int` from `AnandaJSON`
    func extractInt(from json: AnandaJSON) -> Int?

    /// Extract `UInt` from `AnandaJSON`
    func extractUInt(from json: AnandaJSON) -> UInt?

    /// Extract `Double` from `AnandaJSON`
    func extractDouble(from json: AnandaJSON) -> Double?

    /// Extract `String` from `AnandaJSON`
    func extractString(from json: AnandaJSON) -> String?

    /// Extract `Date` from `AnandaJSON`
    func extractDate(from json: AnandaJSON) -> Date?

    /// Extract `URL` from `AnandaJSON`
    func extractURL(from json: AnandaJSON) -> URL?
}

extension JJLISO8601DateFormatter {
    fileprivate static let iso8601DateFormatter1: JJLISO8601DateFormatter = {
        let dateFormatter = JJLISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]

        return dateFormatter
    }()

    fileprivate static let iso8601DateFormatter2: JJLISO8601DateFormatter = {
        let dateFormatter = JJLISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return dateFormatter
    }()
}

extension AnandaValueExtractor {
    /// Extract `Bool` from `AnandaJSON`
    public func extractBool(from json: AnandaJSON) -> Bool? {
        if let bool = json.originalBool {
            return bool
        } else {
            if let int = json.originalInt {
                return int != 0
            }

            return nil
        }
    }

    /// Extract `Int` from `AnandaJSON`
    public func extractInt(from json: AnandaJSON) -> Int? {
        if let int = json.originalInt {
            return int
        } else {
            if let string = json.originalString {
                return Int(string)
            }

            return nil
        }
    }

    /// Extract `UInt` from `AnandaJSON`
    public func extractUInt(from json: AnandaJSON) -> UInt? {
        if let uInt = json.originalUInt {
            return uInt
        } else {
            if let string = json.originalString {
                return UInt(string)
            }

            return nil
        }
    }

    /// Extract `Double` from `AnandaJSON`
    public func extractDouble(from json: AnandaJSON) -> Double? {
        if let double = json.originalDouble {
            return double
        } else {
            if let string = json.originalString {
                return Double(string)
            }

            return nil
        }
    }

    /// Extract `String` from `AnandaJSON`
    public func extractString(from json: AnandaJSON) -> String? {
        if let string = json.originalString {
            return string
        } else {
            if let int = json.originalInt {
                return String(int)
            }

            return nil
        }
    }

    /// Extract `Date` from `AnandaJSON`
    public func extractDate(from json: AnandaJSON) -> Date? {
        if let int = json.originalInt {
            return .init(timeIntervalSince1970: TimeInterval(int))
        }

        if let double = json.originalDouble {
            return .init(timeIntervalSince1970: double)
        }

        if let string = json.originalString {
            if let value = TimeInterval(string) {
                return .init(timeIntervalSince1970: value)
            }

            if let date = JJLISO8601DateFormatter.iso8601DateFormatter1.date(from: string) {
                return date
            }

            if let date = JJLISO8601DateFormatter.iso8601DateFormatter2.date(from: string) {
                return date
            }
        }

        return nil
    }

    /// Extract `URL` from `AnandaJSON`
    public func extractURL(from json: AnandaJSON) -> URL? {
        json.originalString.flatMap {
            URL(string: $0)
        }
    }
}

/// DefaultAnandaValueExtractor
public struct DefaultAnandaValueExtractor: AnandaValueExtractor {
    public init() {}
}
