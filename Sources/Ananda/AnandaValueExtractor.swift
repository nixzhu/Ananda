import Foundation

#if !os(Linux)
import JJLISO8601DateFormatter
#endif

/// AnandaValueExtractor
///
/// Extract value from `AnandaJSON`.
public struct AnandaValueExtractor: Sendable {
    /// Standard shared instance
    public static let standard = Self()

    var bool: @Sendable (AnandaJSON) -> Bool?
    var int: @Sendable (AnandaJSON) -> Int?
    var double: @Sendable (AnandaJSON) -> Double?
    var string: @Sendable (AnandaJSON) -> String?
    var date: @Sendable (AnandaJSON) -> Date?
    var url: @Sendable (AnandaJSON) -> URL?

    /// Initializer
    /// - Parameters:
    ///   - bool: Extract `Bool` from `AnandaJSON`
    ///   - int: Extract `Int` from `AnandaJSON`
    ///   - double: Extract `Double` from `AnandaJSON`
    ///   - string: Extract `String` from `AnandaJSON`
    ///   - date: Extract `Date` from `AnandaJSON`
    ///   - url: Extract `URL` from `AnandaJSON`
    public init(
        bool: @escaping @Sendable (AnandaJSON) -> Bool? = {
            if let bool = $0.originalBool {
                return bool
            } else {
                if let int = $0.originalInt {
                    return int != 0
                }

                return nil
            }
        },
        int: @escaping @Sendable (AnandaJSON) -> Int? = {
            if let int = $0.originalInt {
                return int
            } else {
                if let string = $0.originalString {
                    return Int(string)
                }

                return nil
            }
        },
        double: @escaping @Sendable (AnandaJSON) -> Double? = {
            if let number = $0.originalNumber {
                return number
            } else {
                if let string = $0.originalString {
                    return Double(string)
                }

                return nil
            }
        },
        string: @escaping @Sendable (AnandaJSON) -> String? = {
            if let string = $0.originalString {
                return string
            } else {
                if let int = $0.originalInt {
                    return String(int)
                }

                return nil
            }
        },
        date: @escaping @Sendable (AnandaJSON) -> Date? = {
            if let number = $0.originalNumber {
                return .init(timeIntervalSince1970: number)
            }

            if let string = $0.originalString {
                if let value = TimeInterval(string) {
                    return .init(timeIntervalSince1970: value)
                }

                #if os(Linux)
                if let date = ISO8601DateFormatter.ananda_date(from: string) {
                    return date
                }
                #else
                if let date = JJLISO8601DateFormatter.ananda_date(from: string) {
                    return date
                }
                #endif
            }

            return nil
        },
        url: @escaping @Sendable (AnandaJSON) -> URL? = {
            guard let string = $0.originalString else {
                return nil
            }

            if let url = URL(string: string) {
                return url
            }

            if let encoded = string.addingPercentEncoding(withAllowedCharacters: .ananda_url) {
                return URL(string: encoded)
            }

            return nil
        }
    ) {
        self.bool = bool
        self.int = int
        self.double = double
        self.string = string
        self.date = date
        self.url = url
    }
}

extension AnandaValueExtractor {
    /// Returns updated `Self` with new `bool` extractor.
    public func updatingBool(_ bool: @escaping @Sendable (AnandaJSON) -> Bool?) -> Self {
        var result = self
        result.bool = bool
        return result
    }

    /// Returns updated `Self` with new `int` extractor.
    public func updatingInt(_ int: @escaping @Sendable (AnandaJSON) -> Int?) -> Self {
        var result = self
        result.int = int
        return result
    }

    /// Returns updated `Self` with new `double` extractor.
    public func updatingDouble(_ double: @escaping @Sendable (AnandaJSON) -> Double?) -> Self {
        var result = self
        result.double = double
        return result
    }

    /// Returns updated `Self` with new `string` extractor.
    public func updatingString(_ string: @escaping @Sendable (AnandaJSON) -> String?) -> Self {
        var result = self
        result.string = string
        return result
    }

    /// Returns updated `Self` with new `date` extractor.
    public func updatingDate(_ date: @escaping @Sendable (AnandaJSON) -> Date?) -> Self {
        var result = self
        result.date = date
        return result
    }

    /// Returns updated `Self` with new `url` extractor.
    public func updatingURL(_ url: @escaping @Sendable (AnandaJSON) -> URL?) -> Self {
        var result = self
        result.url = url
        return result
    }
}

#if os(Linux)
#if $RetroactiveAttribute
extension ISO8601DateFormatter: @retroactive @unchecked Sendable {
    public static func ananda_date(from string: String) -> Date? {
        if let date = ananda_iso8601A.date(from: string) {
            return date
        }

        if let date = ananda_iso8601B.date(from: string) {
            return date
        }

        return nil
    }

    private static let ananda_iso8601A: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()

        dateFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds,
        ]

        return dateFormatter
    }()

    private static let ananda_iso8601B: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()

        dateFormatter.formatOptions = [
            .withInternetDateTime,
        ]

        return dateFormatter
    }()
}
#else
extension ISO8601DateFormatter: @unchecked Sendable {
    public static func ananda_date(from string: String) -> Date? {
        if let date = ananda_iso8601A.date(from: string) {
            return date
        }

        if let date = ananda_iso8601B.date(from: string) {
            return date
        }

        return nil
    }

    private static let ananda_iso8601A: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()

        dateFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds,
        ]

        return dateFormatter
    }()

    private static let ananda_iso8601B: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()

        dateFormatter.formatOptions = [
            .withInternetDateTime,
        ]

        return dateFormatter
    }()
}
#endif
#else
#if $RetroactiveAttribute
extension JJLISO8601DateFormatter: @retroactive @unchecked Sendable {
    public static func ananda_date(from string: String) -> Date? {
        if let date = ananda_iso8601A.date(from: string) {
            return date
        }

        if let date = ananda_iso8601B.date(from: string) {
            return date
        }

        return nil
    }

    private static let ananda_iso8601A: JJLISO8601DateFormatter = {
        let dateFormatter = JJLISO8601DateFormatter()

        dateFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds,
        ]

        return dateFormatter
    }()

    private static let ananda_iso8601B: JJLISO8601DateFormatter = {
        let dateFormatter = JJLISO8601DateFormatter()

        dateFormatter.formatOptions = [
            .withInternetDateTime,
        ]

        return dateFormatter
    }()
}
#else
extension JJLISO8601DateFormatter: @unchecked Sendable {
    public static func ananda_date(from string: String) -> Date? {
        if let date = ananda_iso8601A.date(from: string) {
            return date
        }

        if let date = ananda_iso8601B.date(from: string) {
            return date
        }

        return nil
    }

    private static let ananda_iso8601A: JJLISO8601DateFormatter = {
        let dateFormatter = JJLISO8601DateFormatter()

        dateFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds,
        ]

        return dateFormatter
    }()

    private static let ananda_iso8601B: JJLISO8601DateFormatter = {
        let dateFormatter = JJLISO8601DateFormatter()

        dateFormatter.formatOptions = [
            .withInternetDateTime,
        ]

        return dateFormatter
    }()
}
#endif
#endif

#if $RetroactiveAttribute
extension CharacterSet: @retroactive @unchecked Sendable {
    public static let ananda_url: Self = {
        var set = CharacterSet.urlQueryAllowed
        set.insert("#")
        set.formUnion(.urlPathAllowed)

        return set
    }()
}
#else
extension CharacterSet: @unchecked Sendable {
    public static let ananda_url: Self = {
        var set = CharacterSet.urlQueryAllowed
        set.insert("#")
        set.formUnion(.urlPathAllowed)

        return set
    }()
}
#endif
