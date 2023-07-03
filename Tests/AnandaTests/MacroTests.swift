import XCTest
import SwiftSyntaxMacrosTestSupport
@testable import Ananda
@testable import AnandaMacros

final class MacroTests: XCTestCase {
    func testMacro() {
        assertMacroExpansion(
            """
            @AnandaInit
            struct Alice: AnandaModel {
                @AnandaInit
                final class Bob: AnandaModel {
                    let b1: Int
                    let b2: Int?
                    let b3: [Int]
                    let b4: [Int]?
                    let b5: [String: Int]
                    let b6: [String: Int]?
                    let b7: [[String: Int]]
                    let b8: [[String: Int]]?
                }
                @AnandaKey("avatar_url")
                let avatarURL: URL
                let a1: Bool
                let a2: Bool?
                let a3: [Bool]
                let a4: [Bool]?
                let c1: Bob
                let c2: Bob?
                let c3: [Bob]
                let c4: [Bob]?
                let c5: [String: Bob]
                let c6: [String: Bob]?
                let c7: [[String: Bob]]
                let c8: [[String: Bob]]?
            }
            """,
            expandedSource: """
                struct Alice: AnandaModel {
                    final class Bob: AnandaModel {
                        let b1: Int
                        let b2: Int?
                        let b3: [Int]
                        let b4: [Int]?
                        let b5: [String: Int]
                        let b6: [String: Int]?
                        let b7: [[String: Int]]
                        let b8: [[String: Int]]?
                        init(json: AnandaJSON) {
                            self.b1 = json["b1"].int()
                            self.b2 = json["b2"].int
                            self.b3 = json["b3"].array().map {
                                $0.int()
                            }
                            self.b4 = json["b4"].array?.map {
                                $0.int()
                            }
                            self.b5 = json["b5"].dictionary().mapValues {
                                $0.int()
                            }
                            self.b6 = json["b6"].dictionary?.mapValues {
                                $0.int()
                            }
                            self.b7 = json["b7"].array().map {
                                $0.dictionary().mapValues {
                                    $0.int()
                                }
                            }
                            self.b8 = json["b8"].array?.map {
                                $0.dictionary().mapValues {
                                    $0.int()
                                }
                            }
                        }
                    }
                    let avatarURL: URL
                    let a1: Bool
                    let a2: Bool?
                    let a3: [Bool]
                    let a4: [Bool]?
                    let c1: Bob
                    let c2: Bob?
                    let c3: [Bob]
                    let c4: [Bob]?
                    let c5: [String: Bob]
                    let c6: [String: Bob]?
                    let c7: [[String: Bob]]
                    let c8: [[String: Bob]]?
                    init(json: AnandaJSON) {
                        self.avatarURL = json["avatar_url"].url()
                        self.a1 = json["a1"].bool()
                        self.a2 = json["a2"].bool
                        self.a3 = json["a3"].array().map {
                            $0.bool()
                        }
                        self.a4 = json["a4"].array?.map {
                            $0.bool()
                        }
                        self.c1 = .init(json: json["c1"])
                        self.c2 = json["c2"].emptyAsNil?.map {
                            .init(json: $0)
                        }
                        self.c3 = json["c3"].array().map {
                            .init(json: $0)
                        }
                        self.c4 = json["c4"].array?.map {
                            .init(json: $0)
                        }
                        self.c5 = json["c5"].dictionary().mapValues {
                            .init(json: $0)
                        }
                        self.c6 = json["c6"].dictionary?.mapValues {
                            .init(json: $0)
                        }
                        self.c7 = json["c7"].array().map {
                            $0.dictionary().mapValues {
                                .init(json: $0)
                            }
                        }
                        self.c8 = json["c8"].array?.map {
                            $0.dictionary().mapValues {
                                .init(json: $0)
                            }
                        }
                    }
                }
                """,
            macros: [
                "AnandaInit": AnandaInitMacro.self,
                "AnandaKey": AnandaKeyMacro.self,
            ]
        )
    }
}

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

@AnandaInit
struct Mastodon: AnandaModel {
    @AnandaInit
    struct Profile: AnandaModel {
        enum Gender: String {
            case unknown
            case male
            case female
            case other

            init(json: AnandaJSON) {
                self = .init(rawValue: json.string()) ?? .unknown
            }
        }

        let nickname: String
        let username: String
        @AnandaKey("avatar_url")
        let avatarURL: URL
        let gender: Gender
    }

    @AnandaInit
    struct Toot: AnandaModel {
        let id: Int
        let content: String
        @AnandaKey("created_at")
        let createdAt: Date
    }

    let profile: Profile
    let toots: [Toot]
}

@AnandaInit
struct World: AnandaModel {
    @AnandaInit
    struct Company: AnandaModel {
        @AnandaInit
        struct Market: AnandaModel {
            let value: Int
            let targets: [String]?
        }

        let id: UInt
        let motto: String
        let market: Market
        let ceo: String?
    }

    let companies: [String: Company]
}
