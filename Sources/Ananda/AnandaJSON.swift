import Foundation
import yyjson

/// Container of pointer to`yyjson_val`, provides some convenient APIs to access JSON values.
@dynamicMemberLookup public struct AnandaJSON {
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

    /// Bool value if present, or `nil`.
    public var bool: Bool? {
        isBool ? yyjson_get_bool(pointer) : nil
    }

    /// Bool value if present, or `defaultValue` defaults to`false`.
    public func bool(defaultValue: Bool = false) -> Bool {
        bool ?? defaultValue
    }

    /// Bool value (or case from Int, `0` is `false`, otherwise is `true`) if present, or `nil`.
    public var boolOrInt: Bool? {
        bool ?? int.flatMap { $0 != 0 }
    }

    /// Bool value (or case from Int, `0` is `false`, otherwise is `true`) if present,
    /// or `defaultValue` defaults to`false`.
    public func boolOrInt(defaultValue: Bool = false) -> Bool {
        boolOrInt ?? defaultValue
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
    /// Date value from unix timestamp (Int, Double or String), or `nil`.
    public var dateFromUnixTimestamp: Date? {
        if let int {
            return .init(timeIntervalSince1970: TimeInterval(int))
        }

        if let double {
            return .init(timeIntervalSince1970: double)
        }

        if let string, let value = TimeInterval(string) {
            return .init(timeIntervalSince1970: value)
        }

        return nil
    }

    /// Date value from unix timestamp (Int, Double or String),
    /// or `defaultValue` defaults to`Date(timeIntervalSince1970: 0)`.
    public func dateFromUnixTimestamp(
        defaultValue: Date = .init(timeIntervalSince1970: 0)
    ) -> Date {
        dateFromUnixTimestamp ?? defaultValue
    }
}

extension AnandaJSON {
    /// URL value from String, or`nil`.
    public var urlFromString: URL? {
        string.flatMap {
            URL(string: $0)
        }
    }

    /// URL value from String, or `defaultValue` defaults to`URL(string: "/")!`.
    public func urlFromString(defaultValue: URL = .init(string: "/")!) -> URL {
        urlFromString ?? defaultValue
    }
}
