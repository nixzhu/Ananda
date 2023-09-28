import Foundation
import Ananda
import Benchmark

let jsonData = """
    {
        "name": "Ducky Model Editor",
        "introduction": "I'm Ducky, a document-based app that helps you infer models from JSON.",
        "supported_outputs": [
            "JOSN Schema",
            "Swift",
            "Kotlin",
            "Dart",
            "Go",
            "Proto"
        ],
        "developer": {
            "user_id": 42,
            "username": "nixzhu",
            "email": "zhuhongxu@gmail.com",
            "website_url": "https://nixzhu.dev"
        }
    }
    """.data(using: .utf8)!

benchmark("Codable decoding") {
    struct IndieApp: Decodable {
        struct Developer: Decodable {
            let userID: Int
            let username: String
            let email: String
            let websiteURL: URL

            private enum CodingKeys: String, CodingKey {
                case userID = "user_id"
                case username
                case email
                case websiteURL = "website_url"
            }
        }

        let name: String
        let introduction: String
        let supportedOutputs: [String]
        let developer: Developer

        private enum CodingKeys: String, CodingKey {
            case name
            case introduction
            case supportedOutputs = "supported_outputs"
            case developer
        }
    }

    let model = try! JSONDecoder().decode(IndieApp.self, from: jsonData)
    assert(model.developer.userID == 42)
}

benchmark("Ananda decoding") {
    struct IndieApp: AnandaModel {
        struct Developer: AnandaModel {
            let userID: Int
            let username: String
            let email: String
            let websiteURL: URL

            init(json: AnandaJSON) {
                userID = json.user_id.int()
                username = json.username.string()
                email = json.email.string()
                websiteURL = json.website_url.url()
            }
        }

        let name: String
        let introduction: String
        let supportedOutputs: [String]
        let developer: Developer

        init(json: AnandaJSON) {
            name = json.name.string()
            introduction = json.introduction.string()
            supportedOutputs = json.supported_outputs.array().map { $0.string() }
            developer = .init(json: json.developer)
        }
    }

    let model = IndieApp(jsonData)
    assert(model.developer.userID == 42)
}

benchmark("Ananda decoding with Macro") {
    @AnandaInit
    struct IndieApp: AnandaModel {
        @AnandaInit
        struct Developer: AnandaModel {
            @AnandaKey("user_id")
            let userID: Int
            let username: String
            let email: String
            @AnandaKey("website_url")
            let websiteURL: URL
        }

        let name: String
        let introduction: String
        @AnandaKey("supported_outputs")
        let supportedOutputs: [String]
        let developer: Developer
    }

    let model = IndieApp(jsonData)
    assert(model.developer.userID == 42)
}

Benchmark.main()
