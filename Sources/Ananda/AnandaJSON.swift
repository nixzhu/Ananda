import Foundation
import yyjson
import JJLISO8601DateFormatter

/// Container of pointer to`yyjson_val`, provides some convenient APIs to access JSON values.
@dynamicMemberLookup public struct AnandaJSON {
    /// Extracting bool from `AnandaJSON`, user can customize it.
    public static var boolExtractor: (AnandaJSON) -> Bool? = {
        if $0.isBool {
            return yyjson_get_bool($0.pointer)
        } else {
            if let int = $0.int {
                return int != 0
            }

            return nil
        }
    }

    /// Extracting date from `AnandaJSON`, user can customize it.
    public static var dateExtractor: (AnandaJSON) -> Date? = {
        if let int = $0.int {
            return .init(timeIntervalSince1970: TimeInterval(int))
        }

        if let double = $0.double {
            return .init(timeIntervalSince1970: double)
        }

        if let string = $0.string {
            if let value = TimeInterval(string) {
                return .init(timeIntervalSince1970: value)
            }

            if let date = iso8601DateFormatter1.date(from: string) {
                return date
            }

            if let date = iso8601DateFormatter2.date(from: string) {
                return date
            }
        }

        return nil
    }

    /// Extracting url from `AnandaJSON`, user can customize it.
    public static var urlExtractor: (AnandaJSON) -> URL? = {
        $0.string.flatMap {
            URL(string: $0)
        }
    }

    private static let iso8601DateFormatter1: JJLISO8601DateFormatter = {
        let dateFormatter = JJLISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]

        return dateFormatter
    }()

    private static let iso8601DateFormatter2: JJLISO8601DateFormatter = {
        let dateFormatter = JJLISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return dateFormatter
    }()

    private let pointer: UnsafeMutablePointer<yyjson_val>?

    /// Initialize with `pointer`
    public init(pointer: UnsafeMutablePointer<yyjson_val>?) {
        self.pointer = pointer
    }

    /// Object's member value with`dynamicMember` as key
    public subscript(dynamicMember member: String) -> AnandaJSON {
        self[member]
    }

    /// Object's member value with `key`
    public subscript(key: String) -> AnandaJSON {
        .init(pointer: yyjson_obj_get(pointer, key))
    }

    /// Array's member value at `index`
    public subscript(index: Int) -> AnandaJSON {
        .init(pointer: yyjson_arr_get(pointer, index))
    }
}

extension AnandaJSON {
    /// `true` if the value is null or has not value, otherwise `false`.
    public var isNull: Bool {
        guard let pointer else {
            return true
        }

        return yyjson_is_null(pointer)
    }
}

extension AnandaJSON {
    /// `true` if the value is null or is object but size is empty or is array but size is empty,
    /// otherwise `false`.
    public var isEmpty: Bool {
        if isNull {
            return true
        }

        if isObject {
            return yyjson_obj_size(pointer) == 0
        }

        if isArray {
            return yyjson_arr_size(pointer) == 0
        }

        return false
    }
}

extension AnandaJSON {
    /// Whether the value is bool.
    public var isBool: Bool {
        yyjson_is_bool(pointer)
    }

    /// Bool value with `boolExtractor` if present, or `nil`.
    public var bool: Bool? {
        Self.boolExtractor(self)
    }

    /// Bool value with `boolExtractor` if present, or `defaultValue` defaults to`false`.
    public func bool(defaultValue: Bool = false) -> Bool {
        bool ?? defaultValue
    }
}

extension AnandaJSON {
    /// Whether the value is integer.
    public var isInt: Bool {
        yyjson_is_int(pointer)
    }

    /// Int value if present, or `nil`.
    public var int: Int? {
        isInt ? Int(yyjson_get_sint(pointer)) : nil
    }

    /// Int value if present, or `defaultValue` defaults to`0`.
    public func int(defaultValue: Int = 0) -> Int {
        int ?? defaultValue
    }

    /// Int value (or case from String) if present, or `nil`.
    public var intOrString: Int? {
        int ?? string.flatMap { Int($0) }
    }

    /// Int value (or case from String) if present, or `defaultValue` defaults to`0`.
    public func intOrString(defaultValue: Int = 0) -> Int {
        intOrString ?? defaultValue
    }

    /// UInt value if present, or `defaultValue` defaults to`0`.
    public var uInt: UInt? {
        isInt ? UInt(yyjson_get_uint(pointer)) : nil
    }

    /// UInt value if present, or `defaultValue` defaults to`0`.
    public func uInt(defaultValue: UInt = 0) -> UInt {
        uInt ?? defaultValue
    }

    /// UInt value (or case from String) if present, or `nil`.
    public var uIntOrString: UInt? {
        uInt ?? string.flatMap { UInt($0) }
    }

    /// UInt value (or case from String) if present, or `defaultValue` defaults to`0`.
    public func uIntOrString(defaultValue: UInt = 0) -> UInt {
        uIntOrString ?? defaultValue
    }
}

extension AnandaJSON {
    /// Whether the value is double.
    public var isDouble: Bool {
        yyjson_is_real(pointer)
    }

    /// Double value if present, or `nil`.
    public var double: Double? {
        isDouble ? yyjson_get_real(pointer) : nil
    }

    /// Double value if present, or `defaultValue` defaults to`0`.
    public func double(defaultValue: Double = 0) -> Double {
        double ?? defaultValue
    }

    /// Double value (or case from String) if present, or `nil`.
    public var doubleOrString: Double? {
        double ?? string.flatMap { Double($0) }
    }

    /// Double value (or case from String) if present, or `defaultValue` defaults to`0`.
    public func doubleOrString(defaultValue: Double = 0) -> Double {
        doubleOrString ?? defaultValue
    }
}

extension AnandaJSON {
    /// Whether the value is string.
    public var isString: Bool {
        yyjson_is_str(pointer)
    }

    /// String value if present, or `nil`.
    public var string: String? {
        isString ? yyjson_get_str(pointer).flatMap {
            .init(cString: $0)
        } : nil
    }

    /// String value if present, or `defaultValue` defaults to`""`.
    public func string(defaultValue: String = "") -> String {
        string ?? defaultValue
    }

    /// String value (or case from Int) if present, or `nil`.
    public var stringOrInt: String? {
        string ?? int.flatMap { String($0) }
    }

    /// String value (or case from Int) if present, or `defaultValue` defaults to`""`.
    public func stringOrInt(defaultValue: String = "") -> String {
        stringOrInt ?? defaultValue
    }
}

extension AnandaJSON {
    /// Whether the value is object.
    public var isObject: Bool {
        yyjson_is_obj(pointer)
    }

    /// Object value (as dictionary) if present, or `nil`.
    public var dictionary: [String: AnandaJSON]? {
        guard isObject else {
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

    /// Object value (as dictionary) if present, or `defaultValue` defaults to empty dictionary.
    public func dictionary(defaultValue: [String: AnandaJSON] = [:]) -> [String: AnandaJSON] {
        dictionary ?? defaultValue
    }
}

extension AnandaJSON {
    /// Whether the value is array.
    public var isArray: Bool {
        yyjson_is_arr(pointer)
    }

    /// Array value if present, or `nil`.
    public var array: [AnandaJSON]? {
        guard isArray else {
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

    /// Array value if present, or `defaultValue` defaults to empty array.
    public func array(defaultValue: [AnandaJSON] = []) -> [AnandaJSON] {
        array ?? defaultValue
    }
}

extension AnandaJSON {
    /// Date value with `dateExtractor` if present , or `nil`.
    public var date: Date? {
        Self.dateExtractor(self)
    }

    /// Date value with `dateExtractor` if present, or `defaultValue` defaults
    /// to`Date(timeIntervalSince1970: 0)`.
    public func date(defaultValue: Date = .init(timeIntervalSince1970: 0)) -> Date {
        date ?? defaultValue
    }
}

extension AnandaJSON {
    /// URL value with `urlExtractor` if present, or`nil`.
    public var url: URL? {
        Self.urlExtractor(self)
    }

    /// URL value with `urlExtractor` if present, or `defaultValue` defaults to`URL(string: "/")!`.
    public func url(defaultValue: URL = .init(string: "/")!) -> URL {
        url ?? defaultValue
    }
}
