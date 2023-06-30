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
            }
            """,
            expandedSource: """
                struct Alice: AnandaModel {
                    final class Bob: AnandaModel {
                        let b1: Int
                        let b2: Int?
                        let b3: [Int]
                        let b4: [Int]?
                        init(json: AnandaJSON) {
                            self.b1 = json.b1.int()
                            self.b2 = json.b2.int
                            self.b3 = json.b3.array().map {
                                $0.int()
                            }
                            self.b4 = json.b4.isEmpty ? nil : json.b4.array().map {
                                $0.int()
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
                    init(json: AnandaJSON) {
                        self.avatarURL = json.avatar_url.url()
                        self.a1 = json.a1.bool()
                        self.a2 = json.a2.bool
                        self.a3 = json.a3.array().map {
                            $0.bool()
                        }
                        self.a4 = json.a4.isEmpty ? nil : json.a4.array().map {
                            $0.bool()
                        }
                        self.c1 = .init(json: json.c1)
                        self.c2 = json.c2.isEmpty ? nil : .init(json: json.c2)
                        self.c3 = json.c3.array().map {
                            .init(json: $0)
                        }
                        self.c4 = json.c4.isEmpty ? nil : json.c4.array().map {
                            .init(json: $0)
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
struct Alice: AnandaModel {
    @AnandaInit
    final class Bob: AnandaModel {
        let b1: Int
        let b2: Int?
        let b3: [Int]
        let b4: [Int]?
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
}
