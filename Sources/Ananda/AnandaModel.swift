import Foundation
import yyjson

/// AnandaModel can be created from AnandaJSON.
public protocol AnandaModel {
    /// Initialize with `json`.
    init(json: AnandaJSON)
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
                pointer: yyjson_doc_get_root(doc)
            )

            for key in path {
                json = json[key]
            }

            return Self(json: json)
        } else {
            return Self(json: .init(pointer: nil))
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
            return Self(json: .init(pointer: nil))
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
                pointer: yyjson_doc_get_root(doc)
            )

            for key in path {
                json = json[key]
            }

            return json.array().map { .init(json: $0) }
        } else {
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
            return []
        }
    }
}
