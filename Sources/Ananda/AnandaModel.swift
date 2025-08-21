import Foundation
import yyjson

/// AnandaModel can be created from AnandaJSON.
public protocol AnandaModel {
    /// AnandaValueExtractor
    static var valueExtractor: AnandaValueExtractor { get }

    /// Initialize with `json`.
    init(json: AnandaJSON)

    /// Decode from `json`, using type's own `valueExtractor`.
    static func decode(from json: AnandaJSON) -> Self
}

extension AnandaModel {
    /// AnandaValueExtractor defaults to `.standard`.
    public static var valueExtractor: AnandaValueExtractor {
        .standard
    }

    /// Decode from `json`, using type's own `valueExtractor`.
    public static func decode(from json: AnandaJSON) -> Self {
        let json = json.updatingValueExtractor(valueExtractor)
        return Self(json: json)
    }
}

extension AnandaModel {
    /// Decode from `Data`.
    /// - Parameters:
    ///   - data: The `Data` to decode from.
    ///   - path: The path to the value to decode, defaults to `[]`.
    ///   - allowingJSON5: Whether to allow JSON5 format, defaults to `false`.
    /// - Returns: A decoded model.
    public static func decode(
        from data: Data,
        path: [AnandaPathItem] = [],
        allowingJSON5: Bool = false
    ) -> Self {
        let doc = data.withUnsafeBytes {
            yyjson_read(
                $0.bindMemory(to: CChar.self).baseAddress,
                data.count,
                allowingJSON5 ? YYJSON_READ_JSON5 : YYJSON_READ_NOFLAG
            )
        }

        if let doc {
            defer {
                yyjson_doc_free(doc)
            }

            var json = AnandaJSON(
                pointer: yyjson_doc_get_root(doc),
                valueExtractor: Self.valueExtractor
            )

            for item in path {
                switch item {
                case let .key(key):
                    json = json[key]
                case let .index(index):
                    json = json[index]
                }
            }

            return Self(json: json)
        } else {
            return Self(json: .init(pointer: nil, valueExtractor: Self.valueExtractor))
        }
    }

    /// Decode from `String`.
    /// - Parameters:
    ///   - string: The `String` to decode from.
    ///   - path: The path to the value to decode, defaults to `[]`.
    ///   - allowingJSON5: Whether to allow JSON5 format, defaults to `false`.
    ///   - encoding: The `String.Encoding` to use, defaults to `.utf8`.
    /// - Returns: A decoded model.
    public static func decode(
        from string: String,
        path: [AnandaPathItem] = [],
        allowingJSON5: Bool = false,
        encoding: String.Encoding = .utf8
    ) -> Self {
        if let data = string.data(using: encoding) {
            decode(from: data, path: path, allowingJSON5: allowingJSON5)
        } else {
            Self(json: .init(pointer: nil, valueExtractor: Self.valueExtractor))
        }
    }
}

extension Dictionary where Key == String, Value: AnandaModel {
    /// Decode from `Data`.
    /// - Parameters:
    ///   - data: The `Data` to decode from.
    ///   - path: The path to the value to decode, defaults to `[]`.
    ///   - allowingJSON5: Whether to allow JSON5 format, defaults to `false`.
    /// - Returns: A decoded dictionary.
    public static func decode(
        from data: Data,
        path: [AnandaPathItem] = [],
        allowingJSON5: Bool = false
    ) -> Self {
        let doc = data.withUnsafeBytes {
            yyjson_read(
                $0.bindMemory(to: CChar.self).baseAddress,
                data.count,
                allowingJSON5 ? YYJSON_READ_JSON5 : YYJSON_READ_NOFLAG
            )
        }

        if let doc {
            defer {
                yyjson_doc_free(doc)
            }

            var json = AnandaJSON(
                pointer: yyjson_doc_get_root(doc),
                valueExtractor: Value.valueExtractor
            )

            for item in path {
                switch item {
                case let .key(key):
                    json = json[key]
                case let .index(index):
                    json = json[index]
                }
            }

            return json.dictionary().mapValues { .init(json: $0) }
        } else {
            return [:]
        }
    }

    /// Decode from `String`.
    /// - Parameters:
    ///   - string: The `String` to decode from.
    ///   - path: The path to the value to decode, defaults to `[]`.
    ///   - allowingJSON5: Whether to allow JSON5 format, defaults to `false`.
    ///   - encoding: The `String.Encoding` to use, defaults to `.utf8`.
    /// - Returns: A decoded dictionary.
    public static func decode(
        from string: String,
        path: [AnandaPathItem] = [],
        allowingJSON5: Bool = false,
        encoding: String.Encoding = .utf8
    ) -> Self {
        if let data = string.data(using: encoding) {
            decode(from: data, path: path, allowingJSON5: allowingJSON5)
        } else {
            [:]
        }
    }
}

extension Array where Element: AnandaModel {
    /// Decode from `Data`.
    /// - Parameters:
    ///   - data: The `Data` to decode from.
    ///   - path: The path to the value to decode, defaults to `[]`.
    ///   - allowingJSON5: Whether to allow JSON5 format, defaults to `false`.
    /// - Returns: A decoded array.
    public static func decode(
        from data: Data,
        path: [AnandaPathItem] = [],
        allowingJSON5: Bool = false
    ) -> Self {
        let doc = data.withUnsafeBytes {
            yyjson_read(
                $0.bindMemory(to: CChar.self).baseAddress,
                data.count,
                allowingJSON5 ? YYJSON_READ_JSON5 : YYJSON_READ_NOFLAG
            )
        }

        if let doc {
            defer {
                yyjson_doc_free(doc)
            }

            var json = AnandaJSON(
                pointer: yyjson_doc_get_root(doc),
                valueExtractor: Element.valueExtractor
            )

            for item in path {
                switch item {
                case let .key(key):
                    json = json[key]
                case let .index(index):
                    json = json[index]
                }
            }

            return json.array().map { .init(json: $0) }
        } else {
            return []
        }
    }

    /// Decode from `String`.
    /// - Parameters:
    ///   - string: The `String` to decode from.
    ///   - path: The path to the value to decode, defaults to `[]`.
    ///   - allowingJSON5: Whether to allow JSON5 format, defaults to `false`.
    ///   - encoding: The `String.Encoding` to use, defaults to `.utf8`.
    /// - Returns: A decoded array.
    public static func decode(
        from string: String,
        path: [AnandaPathItem] = [],
        allowingJSON5: Bool = false,
        encoding: String.Encoding = .utf8
    ) -> Self {
        if let data = string.data(using: encoding) {
            decode(from: data, path: path, allowingJSON5: allowingJSON5)
        } else {
            []
        }
    }
}
