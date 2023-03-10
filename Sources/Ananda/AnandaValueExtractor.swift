import Foundation
import JJLISO8601DateFormatter

/// AnandaValueExtractor
///
/// Extract value from `AnandaJSON`
public struct AnandaValueExtractor {
    /// Shared instance
    public static let shared = Self()

    let bool: (AnandaJSON) -> Bool?
    let int: (AnandaJSON) -> Int?
    let uInt: (AnandaJSON) -> UInt?
    let double: (AnandaJSON) -> Double?
    let string: (AnandaJSON) -> String?
    let date: (AnandaJSON) -> Date?
    let url: (AnandaJSON) -> URL?

    /// Initializer
    /// - Parameters:
    ///   - bool: Extract `Bool` from `AnandaJSON`
    ///   - int: Extract `Int` from `AnandaJSON`
    ///   - uInt: Extract `UInt` from `AnandaJSON`
    ///   - double: Extract `Double` from `AnandaJSON`
    ///   - string: Extract `String` from `AnandaJSON`
    ///   - date: Extract `Date` from `AnandaJSON`
    ///   - url: Extract `URL` from `AnandaJSON`
    public init(
        bool: @escaping (AnandaJSON) -> Bool? = {
            if let bool = $0.originalBool {
                return bool
            } else {
                if let int = $0.originalInt {
                    return int != 0
                }

                return nil
            }
        },
        int: @escaping (AnandaJSON) -> Int? = {
            if let int = $0.originalInt {
                return int
            } else {
                if let string = $0.originalString {
                    return Int(string)
                }

                return nil
            }
        },
        uInt: @escaping (AnandaJSON) -> UInt? = {
            if let uInt = $0.originalUInt {
                return uInt
            } else {
                if let string = $0.originalString {
                    return UInt(string)
                }

                return nil
            }
        },
        double: @escaping (AnandaJSON) -> Double? = {
            if let double = $0.originalDouble {
                return double
            } else {
                if let string = $0.originalString {
                    return Double(string)
                }

                return nil
            }
        },
        string: @escaping (AnandaJSON) -> String? = {
            if let string = $0.originalString {
                return string
            } else {
                if let int = $0.originalInt {
                    return String(int)
                }

                return nil
            }
        },
        date: @escaping (AnandaJSON) -> Date? = {
            if let int = $0.originalInt {
                return .init(timeIntervalSince1970: TimeInterval(int))
            }

            if let double = $0.originalDouble {
                return .init(timeIntervalSince1970: double)
            }

            if let string = $0.originalString {
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
        },
        url: @escaping (AnandaJSON) -> URL? = {
            $0.originalString.flatMap {
                URL(string: $0)
            }
        }
    ) {
        self.bool = bool
        self.int = int
        self.uInt = uInt
        self.double = double
        self.string = string
        self.date = date
        self.url = url
    }
}

extension JJLISO8601DateFormatter {
    public static let iso8601DateFormatter1: JJLISO8601DateFormatter = {
        let dateFormatter = JJLISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]

        return dateFormatter
    }()

    public static let iso8601DateFormatter2: JJLISO8601DateFormatter = {
        let dateFormatter = JJLISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return dateFormatter
    }()
}
