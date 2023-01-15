import Foundation
import yyjson

/// Container of pointer to`yyjson_val`, provides some convenient APIs to access JSON values.
@dynamicMemberLookup public struct AnandaJSON {
    private let pointer: UnsafeMutablePointer<yyjson_val>?

    public init(pointer: UnsafeMutablePointer<yyjson_val>?) {
        self.pointer = pointer
    }

    public subscript(dynamicMember member: String) -> AnandaJSON {
        self[member]
    }

    public subscript(key: String) -> AnandaJSON {
        .init(
            pointer: pointer.flatMap {
                yyjson_obj_get($0, key)
            }
        )
    }

    public subscript(index: Int) -> AnandaJSON {
        guard let pointer, yyjson_is_arr(pointer) else {
            return .init(pointer: nil)
        }

        let size = yyjson_arr_size(pointer)

        if (0..<size).contains(index) {
            return .init(pointer: yyjson_arr_get(pointer, index))
        } else {
            return .init(pointer: nil)
        }
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
    /// `true` if the value is object, otherwise `false`.
    public var isObject: Bool {
        yyjson_is_obj(pointer)
    }
}

extension AnandaJSON {
    /// `true` if the value is array, otherwise `false`.
    public var isArray: Bool {
        yyjson_is_arr(pointer)
    }
}

extension AnandaJSON {
    /// `true` if the value is null or is object but size is empty or is array but size is empty, otherwise `false`.
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
    /// Bool or `nil`.
    public var optionalBool: Bool? {
        pointer.flatMap {
            yyjson_is_bool($0) ? yyjson_get_bool($0) : nil
        }
    }

    /// Bool or `false`.
    public var bool: Bool {
        optionalBool ?? false
    }
}

extension AnandaJSON {
    /// Int or `nil`.
    public var optionalInt: Int? {
        pointer.flatMap {
            yyjson_is_int($0) ? Int(yyjson_get_sint($0)) : nil
        }
    }

    /// Int or `0`.
    public var int: Int {
        optionalInt ?? 0
    }
}

extension AnandaJSON {
    /// Double or `nil`.
    public var optionalDouble: Double? {
        pointer.flatMap {
            yyjson_is_real($0) ? yyjson_get_real($0) : nil
        }
    }

    /// Double or`0`.
    public var double: Double {
        optionalDouble ?? 0
    }
}

extension AnandaJSON {
    /// String or `nil`.
    public var optionalString: String? {
        pointer.flatMap {
            yyjson_get_str($0).flatMap {
                .init(cString: $0)
            }
        }
    }

    /// String or `""`.
    public var string: String {
        optionalString ?? ""
    }
}

extension AnandaJSON {
    /// String (or case from Int) or `nil`.
    public var optionalStringOrInt: String? {
        optionalString ?? optionalInt.flatMap { String($0) }
    }

    /// String (or case from Int) or `""`.
    public var stringOrInt: String {
        optionalStringOrInt ?? ""
    }
}

extension AnandaJSON {
    /// Int (or case from String) or `nil`.
    public var optionalIntOrString: Int? {
        optionalInt ?? optionalString.flatMap { Int($0) }
    }

    /// Int (or case from String) or `0`.
    public var intOrString: Int {
        optionalIntOrString ?? 0
    }
}

extension AnandaJSON {
    /// Double (or case from String) or `nil`.
    public var optionalDoubleOrString: Double? {
        optionalDouble ?? optionalString.flatMap { Double($0) }
    }

    /// Double (or case from String) or `0`.
    public var doubleOrString: Double {
        optionalDoubleOrString ?? 0
    }
}

extension AnandaJSON {
    /// Object
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
    /// Array
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
    /// Date from unix timestamp (Int, Double or String) or `nil`.
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

    /// Date from unix timestamp (Int, Double or String) or `Date(timeIntervalSince1970: 0)`.
    public var unixDate: Date {
        optionalUnixDate ?? .init(timeIntervalSince1970: 0)
    }
}

extension AnandaJSON {
    /// URL from String or`nil`.
    public var optionalURL: URL? {
        optionalString.flatMap {
            URL(string: $0)
        }
    }

    /// URL from String or `URL(string: "/")!`.
    public var url: URL {
        optionalURL ?? .init(string: "/")!
    }
}
