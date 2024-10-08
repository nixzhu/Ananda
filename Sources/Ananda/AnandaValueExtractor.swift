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

    let bool: @Sendable (AnandaJSON) -> Bool?
    let int: @Sendable (AnandaJSON) -> Int?
    let double: @Sendable (AnandaJSON) -> Double?
    let string: @Sendable (AnandaJSON) -> String?
    let date: @Sendable (AnandaJSON) -> Date?
    let url: @Sendable (AnandaJSON) -> URL?

    /// Initializer
    /// - Parameters:
    ///   - bool: Extract `Bool` from `AnandaJSON`
    ///   - int: Extract `Int` from `AnandaJSON`
    ///   - double: Extract `Double` from `AnandaJSON`
    ///   - string: Extract `String` from `AnandaJSON`
    ///   - date: Extract `Date` from `AnandaJSON`
    ///   - url: Extract `URL` from `AnandaJSON`
    public init(
        bool: @Sendable @escaping (AnandaJSON) -> Bool? = {
            if let bool = $0.originalBool {
                return bool
            } else {
                if let int = $0.originalInt {
                    return int != 0
                }

                return nil
            }
        },
        int: @Sendable @escaping (AnandaJSON) -> Int? = {
            if let int = $0.originalInt {
                return int
            } else {
                if let string = $0.originalString {
                    return Int(string)
                }

                return nil
            }
        },
        double: @Sendable @escaping (AnandaJSON) -> Double? = {
            if let number = $0.originalNumber {
                return number
            } else {
                if let string = $0.originalString {
                    return Double(string)
                }

                return nil
            }
        },
        string: @Sendable @escaping (AnandaJSON) -> String? = {
            if let string = $0.originalString {
                return string
            } else {
                if let int = $0.originalInt {
                    return String(int)
                }

                return nil
            }
        },
        date: @Sendable @escaping (AnandaJSON) -> Date? = {
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
        url: @Sendable @escaping (AnandaJSON) -> URL? = {
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
