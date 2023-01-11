import Foundation
import yyjson

public protocol AnandaModel {
    init(json: AnandaJSON)
}

extension AnandaModel {
    public init(jsonData: Data) {
        let doc = jsonData.withUnsafeBytes {
            yyjson_read($0.bindMemory(to: CChar.self).baseAddress, jsonData.count, 0)
        }

        if let doc {
            self.init(json: .init(pointer: yyjson_doc_get_root(doc)))
            yyjson_doc_free(doc)
        } else {
            assertionFailure("Should not be here!")
            self.init(json: .init(pointer: nil))
        }
    }

    public init(jsonString: String, encoding: String.Encoding = .utf8) {
        if let jsonData = jsonString.data(using: encoding) {
            self.init(jsonData: jsonData)
        } else {
            assertionFailure("Should not be here!")
            self.init(json: .init(pointer: nil))
        }
    }
}
