import Foundation
import yyjson

#if !os(Linux)
import JJLISO8601DateFormatter
#endif

/// A dynamic, type‐safe wrapper around raw `yyjson_val` pointers for JSON access.
@dynamicMemberLookup public struct AnandaJSON {
    private let pointer: UnsafeMutablePointer<yyjson_val>?

    /// Wraps a raw `yyjson_val` pointer.
    public init(pointer: UnsafeMutablePointer<yyjson_val>?) {
        self.pointer = pointer
    }

    /// Enables dot‐syntax for nested object access.
    public subscript(dynamicMember member: String) -> Self {
        self[member]
    }

    /// Access an object field by `key`.
    public subscript(key: String) -> Self {
        .init(pointer: yyjson_obj_get(pointer, key))
    }

    /// Access an array element by `index`.
    public subscript(index: Int) -> Self {
        .init(pointer: yyjson_arr_get(pointer, index))
    }
}

extension AnandaJSON {
    /// Attempts to extract the JSON value as a `Bool`.
    public func rawBool() -> Bool? {
        if yyjson_is_bool(pointer) {
            return yyjson_get_bool(pointer)
        }

        return nil
    }

    /// Attempts to extract the JSON value as an `Int`.
    public func rawInt() -> Int? {
        if yyjson_is_int(pointer) {
            return .init(yyjson_get_sint(pointer))
        }

        return nil
    }

    /// Attempts to extract the JSON value as a `Double`.
    public func rawDouble() -> Double? {
        if yyjson_is_num(pointer) {
            return yyjson_get_num(pointer)
        }

        return nil
    }

    /// Attempts to extract the JSON value as a `String`.
    public func rawString() -> String? {
        if let cString = yyjson_get_str(pointer) {
            return .init(cString: cString)
        }

        return nil
    }
}

extension AnandaJSON {
    /// Defines how boolean values are parsed from JSON.
    public enum BoolMode {
        /// Only accept native JSON `true` or `false`.
        case strict

        /// Also accept integer `0` as `false`, all others as `true`.
        case compatible

        /// Use a custom closure to interpret the JSON.
        case custom((AnandaJSON) -> Bool?)
    }

    /// Attempts to parse the current JSON value as an optional `Bool` using the specified `mode`.
    public func boolIfPresent(_ mode: BoolMode = .strict) -> Bool? {
        switch mode {
        case .strict:
            if yyjson_is_bool(pointer) {
                return yyjson_get_bool(pointer)
            }
        case .compatible:
            if yyjson_is_bool(pointer) {
                return yyjson_get_bool(pointer)
            }

            if yyjson_is_int(pointer) {
                return yyjson_get_sint(pointer) != 0
            }
        case .custom(let parse):
            if let value = parse(self) {
                return value
            }
        }

        return nil
    }

    /// Parses the current JSON value as a `Bool`, returning `false` if missing or invalid.
    public func bool(_ mode: BoolMode = .strict) -> Bool {
        boolIfPresent(mode) ?? false
    }
}

extension AnandaJSON {
    /// Defines how integer values are parsed from JSON.
    public enum IntMode {
        /// Only accept native JSON integers.
        case strict

        /// Also accept numeric strings.
        case compatible

        /// Use a custom closure to interpret the JSON.
        case custom((AnandaJSON) -> Int?)
    }

    /// Attempts to parse the current JSON value as an optional `Int` using the specified `mode`.
    public func intIfPresent(_ mode: IntMode = .strict) -> Int? {
        switch mode {
        case .strict:
            if yyjson_is_int(pointer) {
                return .init(yyjson_get_sint(pointer))
            }
        case .compatible:
            if yyjson_is_int(pointer) {
                return .init(yyjson_get_sint(pointer))
            }

            if let string = yyjson_get_str(pointer).map({ String(cString: $0) }),
               let int = Int(string)
            {
                return int
            }
        case .custom(let parse):
            if let value = parse(self) {
                return value
            }
        }

        return nil
    }

    /// Parses the current JSON value as an `Int`, returning `0` if missing or invalid.
    public func int(_ mode: IntMode = .strict) -> Int {
        intIfPresent(mode) ?? 0
    }
}

extension AnandaJSON {
    /// Defines how floating‐point values are parsed from JSON.
    public enum DoubleMode {
        /// Only accept native JSON numbers.
        case strict

        /// Also accept numeric strings.
        case compatible

        /// Use a custom closure to interpret the JSON.
        case custom((AnandaJSON) -> Double?)
    }

    /// Attempts to parse the current JSON value as an optional `Double` using the specified `mode`.
    public func doubleIfPresent(_ mode: DoubleMode = .strict) -> Double? {
        switch mode {
        case .strict:
            if yyjson_is_num(pointer) {
                return yyjson_get_num(pointer)
            }
        case .compatible:
            if yyjson_is_num(pointer) {
                return yyjson_get_num(pointer)
            }

            if let string = yyjson_get_str(pointer).map({ String(cString: $0) }),
               let double = Double(string)
            {
                return double
            }
        case .custom(let parse):
            if let value = parse(self) {
                return value
            }
        }

        return nil
    }

    /// Parses the current JSON value as a `Double`, returning `0.0` if missing or invalid.
    public func double(_ mode: DoubleMode = .strict) -> Double {
        doubleIfPresent(mode) ?? 0
    }
}

extension AnandaJSON {
    /// Defines how string values are parsed from JSON.
    public enum StringMode {
        /// Only accept native JSON strings.
        case strict

        /// Also accept integers.
        case compatible

        /// Use a custom closure to interpret the JSON.
        case custom((AnandaJSON) -> String?)
    }

    /// Attempts to parse the current JSON value as an optional `String` using the specified `mode`.
    public func stringIfPresent(_ mode: StringMode = .strict) -> String? {
        switch mode {
        case .strict:
            if let cString = yyjson_get_str(pointer) {
                return .init(cString: cString)
            }
        case .compatible:
            if let cString = yyjson_get_str(pointer) {
                return .init(cString: cString)
            }

            if yyjson_is_int(pointer) {
                return .init(yyjson_get_sint(pointer))
            }
        case .custom(let parse):
            if let value = parse(self) {
                return value
            }
        }

        return nil
    }

    /// Parses the current JSON value as a `String`, returning empty string if missing or invalid.
    public func string(_ mode: StringMode = .strict) -> String {
        stringIfPresent(mode) ?? ""
    }
}

extension AnandaJSON {
    /// Defines how URL values are parsed from JSON.
    public enum URLMode {
        /// Only accept well‐formed URLs.
        case strict

        /// Also try percent‐encoding paths.
        case compatible

        /// Use a custom closure to interpret the JSON.
        case custom((AnandaJSON) -> URL?)
    }

    /// Attempts to parse the current JSON value as an optional `URL` using the specified `mode`.
    public func urlIfPresent(_ mode: URLMode = .strict) -> URL? {
        switch mode {
        case .strict:
            if let string = yyjson_get_str(pointer).map({ String(cString: $0) }),
               let url = URL(string: string)
            {
                return url
            }
        case .compatible:
            if let string = yyjson_get_str(pointer).map({ String(cString: $0) }) {
                if let url = URL(string: string) {
                    return url
                }

                if let encoded = string.addingPercentEncoding(withAllowedCharacters: .ananda_url),
                   let url = URL(string: encoded)
                {
                    return url
                }
            }
        case .custom(let parse):
            if let value = parse(self) {
                return value
            }
        }

        return nil
    }

    /// Parses the current JSON value as a `URL`, returning root `/` if missing or invalid.
    public func url(_ mode: URLMode = .strict) -> URL {
        urlIfPresent(mode) ?? .init(string: "/")!
    }
}

extension AnandaJSON {
    /// Defines how Date values are parsed from JSON.
    public enum DateMode {
        /// Interpret numeric or numeric‐string as UNIX timestamp.
        case secondsSince1970

        /// Parse using ISO‐8601 formatter.
        case iso8601

        /// Try both timestamp and ISO‐8601.
        case compatible

        /// Use a custom closure to interpret the JSON.
        case custom((AnandaJSON) -> Date?)
    }

    /// Attempts to parse the current JSON value as an optional `Date` using the specified `mode`.
    public func dateIfPresent(_ mode: DateMode = .compatible) -> Date? {
        switch mode {
        case .secondsSince1970:
            if yyjson_is_num(pointer) {
                let seconds = yyjson_get_num(pointer)
                return .init(timeIntervalSince1970: seconds)
            }

            if let string = yyjson_get_str(pointer).map({ String(cString: $0) }) {
                if let seconds = TimeInterval(string) {
                    return .init(timeIntervalSince1970: seconds)
                }
            }
        case .iso8601:
            if let string = yyjson_get_str(pointer).map({ String(cString: $0) }) {
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
        case .compatible:
            if yyjson_is_num(pointer) {
                let seconds = yyjson_get_num(pointer)
                return .init(timeIntervalSince1970: seconds)
            }

            if let string = yyjson_get_str(pointer).map({ String(cString: $0) }) {
                if let seconds = TimeInterval(string) {
                    return .init(timeIntervalSince1970: seconds)
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
        case .custom(let parse):
            if let value = parse(self) {
                return value
            }
        }

        return nil
    }

    /// Parses the current JSON value as a `Date`, returning the Unix epoch on failure.
    public func date(_ mode: DateMode = .compatible) -> Date {
        dateIfPresent(mode) ?? .init(timeIntervalSince1970: 0)
    }
}

extension AnandaJSON {
    /// Convert the current JSON value to a Swift dictionary if it is an object,
    /// returning `nil` if the object is empty or not an object.
    public func dictionaryIfPresent() -> [String: Self]? {
        guard yyjson_obj_size(pointer) > 0 else {
            return nil
        }

        var result: [String: AnandaJSON] = [:]

        var iter = yyjson_obj_iter()
        yyjson_obj_iter_init(pointer, &iter)

        while true {
            if let key = yyjson_obj_iter_next(&iter),
               let value = yyjson_obj_iter_get_val(key)
            {
                let keyString = yyjson_get_str(key).flatMap {
                    String(cString: $0)
                }

                if let keyString {
                    result[keyString] = .init(pointer: value)
                } else {
                    assertionFailure("Should not be here!")
                }
            } else {
                break
            }
        }

        return result
    }

    /// Convert the current JSON value to a Swift dictionary,
    /// returning an empty dictionary if the value is not an object or the object is empty.
    public func dictionary() -> [String: Self] {
        dictionaryIfPresent() ?? [:]
    }
}

extension AnandaJSON {
    /// Convert the current JSON value to a Swift array if it is an array,
    /// returning `nil` if the array is empty or not an array.
    public func arrayIfPresent() -> [Self]? {
        guard yyjson_arr_size(pointer) > 0 else {
            return nil
        }

        var result: [AnandaJSON] = []

        var iter = yyjson_arr_iter()
        yyjson_arr_iter_init(pointer, &iter)

        while true {
            if let value = yyjson_arr_iter_next(&iter) {
                result.append(.init(pointer: value))
            } else {
                break
            }
        }

        return result
    }

    /// Convert the current JSON value to a Swift array,
    /// returning an empty array if the value is not an array or the array is empty.
    public func array() -> [Self] {
        arrayIfPresent() ?? []
    }
}

extension CharacterSet: @retroactive @unchecked Sendable {
    fileprivate static let ananda_url: Self = {
        var set = CharacterSet.urlQueryAllowed
        set.insert("#")
        set.formUnion(.urlPathAllowed)

        return set
    }()
}

#if os(Linux)
extension ISO8601DateFormatter: @retroactive @unchecked Sendable {
    fileprivate static func ananda_date(from string: String) -> Date? {
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
extension JJLISO8601DateFormatter: @retroactive @unchecked Sendable {
    fileprivate static func ananda_date(from string: String) -> Date? {
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
