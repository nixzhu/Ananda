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
    public var optionalBool: Bool? {
        yyjson_get_bool(pointer)
    }

    /// Bool value if present or `false`.
    public var bool: Bool {
        optionalBool ?? false
    }
}

extension AnandaJSON {
    /// Whether the value is integer.
    public var isInt: Bool {
        yyjson_is_int(pointer)
    }

    /// Int value if present, or `nil`.
    public var optionalInt: Int? {
        isInt ? Int(yyjson_get_sint(pointer)) : nil
    }

    /// Int value if present, or `0`.
    public var int: Int {
        optionalInt ?? 0
    }
}

extension AnandaJSON {
    /// Whether the value is double.
    public var isDouble: Bool {
        yyjson_is_real(pointer)
    }

    /// Double value if present, or `nil`.
    public var optionalDouble: Double? {
        isDouble ? yyjson_get_real(pointer) : nil
    }

    /// Double value if present, or`0`.
    public var double: Double {
        optionalDouble ?? 0
    }
}

extension AnandaJSON {
    /// Whether the value is string.
    public var isString: Bool {
        yyjson_is_str(pointer)
    }

    /// String value if present, or `nil`.
    public var optionalString: String? {
        yyjson_get_str(pointer).flatMap {
            .init(cString: $0)
        }
    }

    /// String value if present, or `""`.
    public var string: String {
        optionalString ?? ""
    }
}

extension AnandaJSON {
    /// String value (or case from Int) if present, or `nil`.
    public var optionalStringOrInt: String? {
        optionalString ?? optionalInt.flatMap { String($0) }
    }

    /// String value (or case from Int) if present, or `""`.
    public var stringOrInt: String {
        optionalStringOrInt ?? ""
    }
}

extension AnandaJSON {
    /// Int value (or case from String) if present, or `nil`.
    public var optionalIntOrString: Int? {
        optionalInt ?? optionalString.flatMap { Int($0) }
    }

    /// Int value (or case from String) if present, or `0`.
    public var intOrString: Int {
        optionalIntOrString ?? 0
    }
}

extension AnandaJSON {
    /// Double value (or case from String) if present, or `nil`.
    public var optionalDoubleOrString: Double? {
        optionalDouble ?? optionalString.flatMap { Double($0) }
    }

    /// Double value (or case from String) if present, or `0`.
    public var doubleOrString: Double {
        optionalDoubleOrString ?? 0
    }
}

extension AnandaJSON {
    /// Whether the value is object.
    public var isObject: Bool {
        yyjson_is_obj(pointer)
    }

    /// Object value if present, or empty dictionary.
    public var object: [String: AnandaJSON] {
        guard isObject else {
            return [:]
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
}

extension AnandaJSON {
    /// Whether the value is array.
    public var isArray: Bool {
        yyjson_is_arr(pointer)
    }

    /// Array value if present, or empty array.
    public var array: [AnandaJSON] {
        guard isArray else {
            return []
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
}

extension AnandaJSON {
    /// Date value from unix timestamp (Int, Double or String), or `nil`.
    public var optionalUnixDate: Date? {
        if let int = optionalInt {
            return .init(timeIntervalSince1970: TimeInterval(int))
        }

        if let double = optionalDouble {
            return .init(timeIntervalSince1970: double)
        }

        if let string = optionalString, let value = TimeInterval(string) {
            return .init(timeIntervalSince1970: value)
        }

        return nil
    }

    /// Date value from unix timestamp (Int, Double or String), or `Date(timeIntervalSince1970: 0)`.
    public var unixDate: Date {
        optionalUnixDate ?? .init(timeIntervalSince1970: 0)
    }
}

extension AnandaJSON {
    /// URL value from String, or`nil`.
    public var optionalURL: URL? {
        optionalString.flatMap {
            URL(string: $0)
        }
    }

    /// URL value from String, or `URL(string: "/")!`.
    public var url: URL {
        optionalURL ?? .init(string: "/")!
    }
}
