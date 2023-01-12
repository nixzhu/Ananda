import Foundation
import yyjson

@dynamicMemberLookup
public struct AnandaJSON {
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
    public var isNull: Bool {
        guard let pointer else {
            return true
        }

        return yyjson_is_null(pointer)
    }
}

extension AnandaJSON {
    public var isEmpty: Bool {
        if isNull {
            return true
        }

        if yyjson_is_obj(pointer) {
            return yyjson_obj_size(pointer) == 0
        }

        if yyjson_is_arr(pointer) {
            return yyjson_arr_size(pointer) == 0
        }

        return false
    }
}

extension AnandaJSON {
    public var bool: Bool? {
        pointer.flatMap {
            yyjson_is_bool($0) ? yyjson_get_bool($0) : nil
        }
    }

    public var boolValue: Bool {
        bool ?? false
    }
}

extension AnandaJSON {
    public var int: Int? {
        pointer.flatMap {
            yyjson_is_int($0) ? Int(yyjson_get_sint($0)) : nil
        }
    }

    public var intValue: Int {
        int ?? 0
    }
}

extension AnandaJSON {
    public var double: Double? {
        pointer.flatMap {
            yyjson_is_real($0) ? yyjson_get_real($0) : nil
        }
    }

    public var doubleValue: Double {
        double ?? 0
    }
}

extension AnandaJSON {
    public var string: String? {
        pointer.flatMap {
            yyjson_get_str($0).flatMap {
                .init(cString: $0)
            }
        }
    }

    public var stringValue: String {
        string ?? ""
    }
}

extension AnandaJSON {
    public var stringOrInt: String? {
        string ?? int.flatMap { String($0) }
    }

    public var stringOrIntValue: String {
        stringOrInt ?? ""
    }
}

extension AnandaJSON {
    public var intOrString: Int? {
        int ?? string.flatMap { Int($0) }
    }

    public var intOrStringValue: Int {
        intOrString ?? 0
    }
}

extension AnandaJSON {
    public var doubleOrString: Double? {
        double ?? string.flatMap { Double($0) }
    }

    public var doubleOrStringValue: Double {
        doubleOrString ?? 0
    }
}

extension AnandaJSON {
    public var dictionaryValue: [String: AnandaJSON] {
        guard let pointer, yyjson_is_obj(pointer) else {
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
    public var arrayValue: [AnandaJSON] {
        guard let pointer, yyjson_is_arr(pointer) else {
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
    public var unixDate: Date? {
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

    public var unixDateValue: Date {
        unixDate ?? .init(timeIntervalSince1970: 0)
    }
}

extension AnandaJSON {
    public var url: URL? {
        if let string, let url = URL(string: string) {
            return url
        }

        return nil
    }

    public var urlValue: URL {
        url ?? URL(string: "/")!
    }
}
