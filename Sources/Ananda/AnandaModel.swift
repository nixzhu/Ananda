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
    /// Initialize with `jsonData`
    public init(_ jsonData: Data) {
        let doc = jsonData.withUnsafeBytes {
            yyjson_read($0.bindMemory(to: CChar.self).baseAddress, jsonData.count, 0)
        }

        if let doc {
            self.init(
                json: .init(
                    pointer: yyjson_doc_get_root(doc),
                    valueExtractor: Self.valueExtractor
                )
            )

            yyjson_doc_free(doc)
        } else {
            assertionFailure("Invalid JSON: \(String(data: jsonData, encoding: .utf8) ?? "")")
            self.init(json: .init(pointer: nil, valueExtractor: Self.valueExtractor))
        }
    }

    /// Initialize with `jsonString`, `encoding` default to `.utf8`
    public init(_ jsonString: String, encoding: String.Encoding = .utf8) {
        if let jsonData = jsonString.data(using: encoding) {
            self.init(jsonData)
        } else {
            assertionFailure("Invalid JSON: \(jsonString)")
            self.init(json: .init(pointer: nil, valueExtractor: Self.valueExtractor))
        }
    }
}
