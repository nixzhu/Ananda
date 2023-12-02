import Foundation
import yyjson

/// AnandaModel can be created from AnandaJSON
public protocol AnandaModel {
    /// AnandaValueExtractor
    static var valueExtractor: AnandaValueExtractor { get }

    /// Initialize with `json`
    init(json: AnandaJSON)
}

extension AnandaModel {
    /// AnandaValueExtractor
    public static var valueExtractor: AnandaValueExtractor {
        .shared
    }
}

extension AnandaModel {
    /// Decode from `jsonData`
    public static func decode(from jsonData: Data) -> Self {
        let doc = jsonData.withUnsafeBytes {
            yyjson_read($0.bindMemory(to: CChar.self).baseAddress, jsonData.count, 0)
        }

        if let doc {
            let json = AnandaJSON(
                pointer: yyjson_doc_get_root(doc),
                valueExtractor: Self.valueExtractor
            )

            let model = Self(json: json)

            yyjson_doc_free(doc)

            return model
        } else {
            assertionFailure("Invalid JSON: \(String(data: jsonData, encoding: .utf8) ?? "")")

            return Self(json: .init(pointer: nil, valueExtractor: Self.valueExtractor))
        }
    }

    /// Decode from `jsonString`, `encoding` default to `.utf8`
    public static func decode(from jsonString: String, encoding: String.Encoding = .utf8) -> Self {
        if let jsonData = jsonString.data(using: encoding) {
            return decode(from: jsonData)
        } else {
            assertionFailure("Invalid JSON: \(jsonString)")

            return Self(json: .init(pointer: nil, valueExtractor: Self.valueExtractor))
        }
    }
}
