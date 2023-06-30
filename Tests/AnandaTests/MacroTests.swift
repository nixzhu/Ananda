import XCTest
import SwiftSyntaxMacrosTestSupport
@testable import AnandaMacros

final class MacroTests: XCTestCase {
    func testMacro() {
        assertMacroExpansion(
            """
            @AnandaInit
            struct A: AnandaModel {
                @AnandaInit
                class B: AnandaModel {
                    let b1: Int
                    let b2: Int?
                    let b3: [Int]
                    let b4: [Int]?
                }
                let a1: Bool
                let a2: Bool?
                let a3: [Bool]
                let a4: [Bool]?
                let c1: B
                let c2: B?
                let c3: [B]
                let c4: [B]?
            }
            """,
            expandedSource: """
                struct A: AnandaModel {
                    class B: AnandaModel {
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
                    let a1: Bool
                    let a2: Bool?
                    let a3: [Bool]
                    let a4: [Bool]?
                    let c1: B
                    let c2: B?
                    let c3: [B]
                    let c4: [B]?
                    init(json: AnandaJSON) {
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
            macros: ["AnandaInit": AnandaInitMacro.self]
        )
    }
}
