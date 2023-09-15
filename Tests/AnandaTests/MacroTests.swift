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
                    let b7: [String: [Int]]
                    let b8: [String: [Int]]?
                    let b9: [[String: Int]]
                    let b10: [[String: Int]]?
                    let b11: [[String: [Int]]]
                    let b12: [[String: [Int]]]?
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
                let c7: [String: [Bob]]
                let c8: [String: [Bob]]?
                let c9: [[String: Bob]]
                let c10: [[String: Bob]]?
                let c11: [[String: [Bob]]]
                let c12: [[String: [Bob]]]?
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
                        let b7: [String: [Int]]
                        let b8: [String: [Int]]?
                        let b9: [[String: Int]]
                        let b10: [[String: Int]]?
                        let b11: [[String: [Int]]]
                        let b12: [[String: [Int]]]?

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
                            self.b7 = json["b7"].dictionary().mapValues {
                                $0.array().map {
                                    $0.int()
                                }
                            }
                            self.b8 = json["b8"].dictionary?.mapValues {
                                $0.array().map {
                                    $0.int()
                                }
                            }
                            self.b9 = json["b9"].array().map {
                                $0.dictionary().mapValues {
                                    $0.int()
                                }
                            }
                            self.b10 = json["b10"].array?.map {
                                $0.dictionary().mapValues {
                                    $0.int()
                                }
                            }
                            self.b11 = json["b11"].array().map {
                                $0.dictionary().mapValues {
                                    $0.array().map {
                                        $0.int()
                                    }
                                }
                            }
                            self.b12 = json["b12"].array?.map {
                                $0.dictionary().mapValues {
                                    $0.array().map {
                                        $0.int()
                                    }
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
                    let c7: [String: [Bob]]
                    let c8: [String: [Bob]]?
                    let c9: [[String: Bob]]
                    let c10: [[String: Bob]]?
                    let c11: [[String: [Bob]]]
                    let c12: [[String: [Bob]]]?

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
                        self.c7 = json["c7"].dictionary().mapValues {
                            $0.array().map {
                                .init(json: $0)
                            }
                        }
                        self.c8 = json["c8"].dictionary?.mapValues {
                            $0.array().map {
                                .init(json: $0)
                            }
                        }
                        self.c9 = json["c9"].array().map {
                            $0.dictionary().mapValues {
                                .init(json: $0)
                            }
                        }
                        self.c10 = json["c10"].array?.map {
                            $0.dictionary().mapValues {
                                .init(json: $0)
                            }
                        }
                        self.c11 = json["c11"].array().map {
                            $0.dictionary().mapValues {
                                $0.array().map {
                                    .init(json: $0)
                                }
                            }
                        }
                        self.c12 = json["c12"].array?.map {
                            $0.dictionary().mapValues {
                                $0.array().map {
                                    .init(json: $0)
                                }
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

    func testComputedOrIgnoredProperties() {
        assertMacroExpansion(
            """
            @AnandaInit
            public struct IDs: APICodable {
                public var id: Int { trakt }

                public let trakt: Int
                public let slug: String?
                public let tvdb: Int?
                public let imdb: String?
                public let tmdb: Int
            
                @AnandaIgnored
                public var poster: URL?
            }
            """,
            expandedSource: """
                public struct IDs: APICodable {
                    public var id: Int { trakt }

                    public let trakt: Int
                    public let slug: String?
                    public let tvdb: Int?
                    public let imdb: String?
                    public let tmdb: Int

                    @AnandaIgnored
                    public var poster: URL?

                    public init(json: AnandaJSON) {
                        self.trakt = json["trakt"].int()
                        self.slug = json["slug"].string
                        self.tvdb = json["tvdb"].int
                        self.imdb = json["imdb"].string
                        self.tmdb = json["tmdb"].int()
                    }
                }
                """,
            macros: [
                "AnandaInit": AnandaInitMacro.self,
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
public struct World: AnandaModel {
    @AnandaInit
    public final class Company: AnandaModel {
        @AnandaInit
        public struct Market: AnandaModel {
            public let value: Int
            public let targets: [String]?
        }

        public let id: UInt
        public let motto: String
        public let market: Market
        public let ceo: String?
    }

    public let companies: [String: Company]
}
