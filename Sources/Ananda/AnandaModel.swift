import Foundation
import yyjson

/// AnandaModel can be created from AnandaJSON.
public protocol AnandaModel {
    /// AnandaValueExtractor
    static var valueExtractor: AnandaValueExtractor { get }

    /// Initialize with `json`.
    init(json: AnandaJSON)
}

extension AnandaModel {
    /// AnandaValueExtractor defaults to `.standard`.
    public static var valueExtractor: AnandaValueExtractor {
        .standard
    }
}

extension AnandaModel {
    /// Decode from `jsonData`, with `path` defaults to `[]`.
    public static func decode(
        from jsonData: Data,
        path: [String] = []
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

            for key in path {
                json = json[key]
            }

            return Self(json: json)
        } else {
            assertionFailure("Invalid JSON: \(String(data: jsonData, encoding: .utf8) ?? "")")

            return Self(json: .init(pointer: nil, valueExtractor: Self.valueExtractor))
        }
    }

    /// Decode from `jsonString`, with `path` defaults to `[]`, `encoding` defaults to `.utf8`.
    public static func decode(
        from jsonString: String,
        path: [String] = [],
        encoding: String.Encoding = .utf8
    ) -> Self {
        if let jsonData = jsonString.data(using: encoding) {
            return decode(from: jsonData, path: path)
        } else {
            assertionFailure("Invalid JSON: \(jsonString)")

            return Self(json: .init(pointer: nil, valueExtractor: Self.valueExtractor))
        }
    }
}

extension Array where Element: AnandaModel {
    /// Decode from `jsonData`, with `path` defaults to `[]`.
    public static func decode(
        from jsonData: Data,
        path: [String] = []
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

            for key in path {
                json = json[key]
            }

            return json.array().map { .init(json: $0) }
        } else {
            assertionFailure("Invalid JSON: \(String(data: jsonData, encoding: .utf8) ?? "")")

            return []
        }
    }

    /// Decode from `jsonString`, with `path` defaults to `[]`, `encoding` defaults to `.utf8`.
    public static func decode(
        from jsonString: String,
        path: [String] = [],
        encoding: String.Encoding = .utf8
    ) -> Self {
        if let jsonData = jsonString.data(using: encoding) {
            return decode(from: jsonData, path: path)
        } else {
            assertionFailure("Invalid JSON: \(jsonString)")

            return []
        }
    }
}
