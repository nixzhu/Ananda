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
    /// Decode from `jsonData`, with `path` defaults to `[]`.
    public static func decode(
        from jsonData: Data,
        path: [AnandaPathItem] = []
    ) -> Self {
        let doc = jsonData.withUnsafeBytes {
            yyjson_read($0.bindMemory(to: CChar.self).baseAddress, jsonData.count, 0)
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

    /// Decode from `jsonString`, with `path` defaults to `[]`, `encoding` defaults to `.utf8`.
    public static func decode(
        from jsonString: String,
        path: [AnandaPathItem] = [],
        encoding: String.Encoding = .utf8
    ) -> Self {
        if let jsonData = jsonString.data(using: encoding) {
            decode(from: jsonData, path: path)
        } else {
            Self(json: .init(pointer: nil, valueExtractor: Self.valueExtractor))
        }
    }
}

extension Dictionary where Key == String, Value: AnandaModel {
    /// Decode from `jsonData`, with `path` defaults to `[]`.
    public static func decode(
        from jsonData: Data,
        path: [AnandaPathItem] = []
    ) -> Self {
        let doc = jsonData.withUnsafeBytes {
            yyjson_read($0.bindMemory(to: CChar.self).baseAddress, jsonData.count, 0)
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

    /// Decode from `jsonString`, with `path` defaults to `[]`, `encoding` defaults to `.utf8`.
    public static func decode(
        from jsonString: String,
        path: [AnandaPathItem] = [],
        encoding: String.Encoding = .utf8
    ) -> Self {
        if let jsonData = jsonString.data(using: encoding) {
            decode(from: jsonData, path: path)
        } else {
            [:]
        }
    }
}

extension Array where Element: AnandaModel {
    /// Decode from `jsonData`, with `path` defaults to `[]`.
    public static func decode(
        from jsonData: Data,
        path: [AnandaPathItem] = []
    ) -> Self {
        let doc = jsonData.withUnsafeBytes {
            yyjson_read($0.bindMemory(to: CChar.self).baseAddress, jsonData.count, 0)
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

    /// Decode from `jsonString`, with `path` defaults to `[]`, `encoding` defaults to `.utf8`.
    public static func decode(
        from jsonString: String,
        path: [AnandaPathItem] = [],
        encoding: String.Encoding = .utf8
    ) -> Self {
        if let jsonData = jsonString.data(using: encoding) {
            decode(from: jsonData, path: path)
        } else {
            []
        }
    }
}
