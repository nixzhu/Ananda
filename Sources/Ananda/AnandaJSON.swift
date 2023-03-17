import Foundation
import yyjson

/// Container of pointer to `yyjson_val`, provides some convenient APIs to access JSON values.
@dynamicMemberLookup public struct AnandaJSON {
    private let pointer: UnsafeMutablePointer<yyjson_val>?
    private let valueExtractor: AnandaValueExtractor

    /// Initialize with `pointer` and `valueExtractor`.
    public init(
        pointer: UnsafeMutablePointer<yyjson_val>?,
        valueExtractor: AnandaValueExtractor
    ) {
        self.pointer = pointer
        self.valueExtractor = valueExtractor
    }

    /// Object's member value with`dynamicMember` as key
    public subscript(dynamicMember member: String) -> AnandaJSON {
        self[member]
    }

    /// Object's member value with `key`
    public subscript(key: String) -> AnandaJSON {
        .init(
            pointer: yyjson_obj_get(pointer, key),
            valueExtractor: valueExtractor
        )
    }

    /// Array's member value at `index`
    public subscript(index: Int) -> AnandaJSON {
        .init(
            pointer: yyjson_arr_get(pointer, index),
            valueExtractor: valueExtractor
        )
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
    /// `true` if the value is null or is dictionary but size is empty or is array but size is
    /// empty, otherwise `false`.
    public var isEmpty: Bool {
        if isNull {
            return true
        }

        if isDictionary {
            return yyjson_obj_size(pointer) == 0
        }

        if isArray {
            return yyjson_arr_size(pointer) == 0
        }

        return false
    }
}

extension AnandaJSON {
    /// Whether the original value is bool.
    public var isOriginalBool: Bool {
        yyjson_is_bool(pointer)
    }

    /// Bool value if present, or `nil`.
    public var originalBool: Bool? {
        isOriginalBool ? yyjson_get_bool(pointer) : nil
    }

    /// Bool value with `valueExtractor` if present, or `nil`.
    public var bool: Bool? {
        valueExtractor.bool(self)
    }

    /// Bool value with `valueExtractor` if present, or `defaultValue` defaults to `false`.
    public func bool(defaultValue: Bool = false) -> Bool {
        bool ?? defaultValue
    }
}

extension AnandaJSON {
    /// Whether the original value is integer.
    public var isOriginalInt: Bool {
        yyjson_is_int(pointer)
    }

    /// Int value if present, or `nil`.
    public var originalInt: Int? {
        isOriginalInt ? Int(yyjson_get_sint(pointer)) : nil
    }

    /// Int value with `valueExtractor`if present, or `nil`.
    public var int: Int? {
        valueExtractor.int(self)
    }

    /// Int value with `valueExtractor` if present, or `defaultValue` defaults to `0`.
    public func int(defaultValue: Int = 0) -> Int {
        int ?? defaultValue
    }

    /// UInt value if present, or `nil`.
    public var originalUInt: UInt? {
        isOriginalInt ? UInt(yyjson_get_uint(pointer)) : nil
    }

    /// UInt value with `valueExtractor` if present, or `defaultValue` defaults to `0`.
    public var uInt: UInt? {
        valueExtractor.uInt(self)
    }

    /// UInt value with `valueExtractor` if present, or `defaultValue` defaults to `0`.
    public func uInt(defaultValue: UInt = 0) -> UInt {
        uInt ?? defaultValue
    }
}

extension AnandaJSON {
    /// Whether the original value is double.
    public var isOriginalDouble: Bool {
        yyjson_is_real(pointer)
    }

    /// Double value if present, or `nil`.
    public var originalDouble: Double? {
        isOriginalDouble ? yyjson_get_real(pointer) : nil
    }

    /// Double value with `valueExtractor` if present, or `nil`.
    public var double: Double? {
        valueExtractor.double(self)
    }

    /// Double value with `valueExtractor` if present, or `defaultValue` defaults to `0`.
    public func double(defaultValue: Double = 0) -> Double {
        double ?? defaultValue
    }
}

extension AnandaJSON {
    /// Whether the original value is string.
    public var isOriginalString: Bool {
        yyjson_is_str(pointer)
    }

    /// String value if present, or `nil`.
    public var originalString: String? {
        isOriginalString
            ? yyjson_get_str(pointer).flatMap {
                String(cString: $0)
            }
            : nil
    }

    /// String value with `valueExtractor` if present, or `nil`.
    public var string: String? {
        valueExtractor.string(self)
    }

    /// String value with `valueExtractor` if present, or `defaultValue` defaults to `""`.
    public func string(defaultValue: String = "") -> String {
        string ?? defaultValue
    }
}

extension AnandaJSON {
    /// Whether the value is object.
    public var isDictionary: Bool {
        yyjson_is_obj(pointer)
    }

    /// Dictionary if present, or `nil`.
    public var dictionary: [String: AnandaJSON]? {
        guard isDictionary else {
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
                    result[keyString] = .init(
                        pointer: value,
                        valueExtractor: valueExtractor
                    )
                } else {
                    assertionFailure("Should not be here!")
                }
            } else {
                break
            }
        }

        return result
    }

    /// Dictionary if present, or `defaultValue` defaults to empty dictionary.
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
                result.append(.init(pointer: value, valueExtractor: valueExtractor))
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
    /// Date value with `valueExtractor` if present , or `nil`.
    public var date: Date? {
        valueExtractor.date(self)
    }

    /// Date value with `valueExtractor` if present, or `defaultValue` defaults
    /// to `Date(timeIntervalSince1970: 0)`.
    public func date(defaultValue: Date = .init(timeIntervalSince1970: 0)) -> Date {
        date ?? defaultValue
    }
}

extension AnandaJSON {
    /// URL value with `valueExtractor` if present, or`nil`.
    public var url: URL? {
        valueExtractor.url(self)
    }

    /// URL value with `valueExtractor` if present, or `defaultValue` defaults to `URL(string: "/")!`.
    public func url(defaultValue: URL = .init(string: "/")!) -> URL {
        url ?? defaultValue
    }
}
