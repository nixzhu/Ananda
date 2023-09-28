import XCTest
@testable import Ananda

final class AnandaTests: XCTestCase {
    func testBool() {
        struct Model: AnandaModel {
            let a: Bool
            let b: Bool
            let c: Bool
            let d: Bool
            let e: Bool
            let f: Bool
            let g: Bool
            let h: Bool
            let i: Bool
            let j: Bool?
            let k: Bool?
            let l: Bool?

            init(json: AnandaJSON) {
                a = json.a.bool()
                b = json.b.bool()
                c = json.c.bool()
                d = json.d.bool()
                e = json.e.bool()
                f = json.f.bool()
                g = json.g.bool()
                h = json.h.bool()
                i = json.i.bool()
                j = json.j.bool
                k = json.k.bool
                l = json.l.bool
            }
        }

        let jsonString = """
            {
                "a": true,
                "b": false,
                "c": 0,
                "d": 1,
                "e": -1,
                "f": 100,
                "g": "true",
                "h": "false",
                "i": "",
                "j": "true",
                "k": "false",
                "l": ""
            }
            """

        let model = Model(jsonString)
        XCTAssertEqual(model.a, true)
        XCTAssertEqual(model.b, false)
        XCTAssertEqual(model.c, false)
        XCTAssertEqual(model.d, true)
        XCTAssertEqual(model.e, true)
        XCTAssertEqual(model.f, true)
        XCTAssertEqual(model.g, false)
        XCTAssertEqual(model.h, false)
        XCTAssertEqual(model.i, false)
        XCTAssertEqual(model.j, nil)
        XCTAssertEqual(model.k, nil)
        XCTAssertEqual(model.l, nil)
    }

    func testInt() {
        struct Model: AnandaModel {
            let a: Int
            let b: Int
            let c: Int
            let d: Int
            let e: Int
            let f: Int
            let g: Int
            let h: Int
            let i: Int
            let j: Int?
            let k: Int?
            let l: Int?

            init(json: AnandaJSON) {
                a = json.a.int()
                b = json.b.int()
                c = json.c.int()
                d = json.d.int()
                e = json.e.int()
                f = json.f.int()
                g = json.g.int()
                h = json.h.int()
                i = json.i.int()
                j = json.j.int
                k = json.k.int
                l = json.l.int
            }
        }

        let jsonData = """
            {
                "a": -1,
                "b": 0,
                "c": 1,
                "d": "-1",
                "e": "0",
                "f": "1",
                "g": "",
                "h": "1.2",
                "i": 4.5,
                "j": "",
                "k": "1.2",
                "l": 4.5
            }
            """.data(using: .utf8)!

        let model = Model(jsonData)
        XCTAssertEqual(model.a, -1)
        XCTAssertEqual(model.b, 0)
        XCTAssertEqual(model.c, 1)
        XCTAssertEqual(model.d, -1)
        XCTAssertEqual(model.e, 0)
        XCTAssertEqual(model.f, 1)
        XCTAssertEqual(model.g, 0)
        XCTAssertEqual(model.h, 0)
        XCTAssertEqual(model.i, 0)
        XCTAssertEqual(model.j, nil)
        XCTAssertEqual(model.k, nil)
        XCTAssertEqual(model.l, nil)
    }

    func testDouble() {
        struct Model: AnandaModel {
            let a: Double
            let b: Double
            let c: Double
            let d: Double
            let e: Double
            let f: Double
            let g: Double
            let h: Double
            let i: Double
            let j: Double?
            let k: Double?
            let l: Double?

            init(json: AnandaJSON) {
                a = json.a.double()
                b = json.b.double()
                c = json.c.double()
                d = json.d.double()
                e = json.e.double()
                f = json.f.double()
                g = json.g.double()
                h = json.h.double()
                i = json.i.double()
                j = json.j.double
                k = json.k.double
                l = json.l.double
            }
        }

        let jsonData = """
            {
                "a": -1.0,
                "b": 0.0,
                "c": 1.0,
                "d": "-1.0",
                "e": "0.0",
                "f": "1.0",
                "g": "",
                "h": "2",
                "i": 5,
                "j": "",
                "k": "2",
                "l": 5
            }
            """.data(using: .utf8)!

        let model = Model(jsonData)
        XCTAssertEqual(model.a, -1)
        XCTAssertEqual(model.b, 0)
        XCTAssertEqual(model.c, 1)
        XCTAssertEqual(model.d, -1)
        XCTAssertEqual(model.e, 0)
        XCTAssertEqual(model.f, 1)
        XCTAssertEqual(model.g, 0)
        XCTAssertEqual(model.h, 2)
        XCTAssertEqual(model.i, 5)
        XCTAssertEqual(model.j, nil)
        XCTAssertEqual(model.k, 2)
        XCTAssertEqual(model.l, 5)
    }

    func testObject() {
        struct User: AnandaModel {
            struct Mastodon: AnandaModel {
                let profile: Profile
                let toots: [Toot]

                init(json: AnandaJSON) {
                    profile = .init(json: json.profile)
                    toots = json.toots.array().map { .init(json: $0) }

                    assert(json.toots[-1].id.int == nil)
                    assert(json.toots[0].id.int == 1)
                    assert(json.toots[1].id.int == 2)
                    assert(json.toots[2].id.int == 88_888_888_888_888_888)
                    assert(json.toots[3].id.int == 99_999_999_999_999_999)
                }
            }

            struct Toot: AnandaModel {
                let id: Int
                let content: String
                let isProtected: Bool
                let createdAt: Date

                init(json: AnandaJSON) {
                    id = json.id.int()
                    content = json.content.string()
                    isProtected = json.is_protected.bool()
                    createdAt = json.created_at.date()
                }
            }

            struct Profile: AnandaModel {
                let username: String
                let nickname: String
                let avatarURL: URL
                let mp3URL: URL

                init(json: AnandaJSON) {
                    username = json.username.string()
                    nickname = json.nickname.string()
                    avatarURL = json.avatar_url.url()
                    mp3URL = json.mp3_url.url()
                }
            }

            static var valueExtractor: AnandaValueExtractor {
                .init(
                    bool: {
                        if let bool = $0.originalBool {
                            return bool
                        } else {
                            if let int = $0.originalInt {
                                return int != 0
                            }

                            if let string = $0.originalString {
                                switch string {
                                case "true":
                                    return true
                                case "false":
                                    return false
                                default:
                                    break
                                }
                            }

                            return nil
                        }
                    }
                )
            }

            let id: UInt
            let name: String
            let int: Int
            let mastodon: Mastodon

            init(json: AnandaJSON) {
                id = json.id.uInt()
                name = json.name.string()
                int = json["int"].int()
                mastodon = .init(json: json.mastodon)

                assert(json.unknown.isNull)
                assert(json["unknown"].isNull)
                assert(!json.name.isNull)
                assert(!json.mastodon.isNull)
                assert(!json.mastodon.profile.isNull)
                assert(!json.mastodon.profile.extra_info.isNull)
                assert(!json.mastodon.profile.extra_list.isNull)

                assert(json.unknown.isEmpty)
                assert(json["unknown"].isEmpty)
                assert(!json.name.isEmpty)
                assert(!json.mastodon.isEmpty)
                assert(!json.mastodon.profile.isEmpty)
                assert(json.mastodon.profile.extra_info.isEmpty)
                assert(json.mastodon.profile.extra_list.isEmpty)

                let mastodonInfo = json.mastodon.dictionary()
                assert(mastodonInfo["profile"]?.username.string == "@nixzhu@mastodon.social")
            }
        }

        let jsonString = """
            {
                "id": 42,
                "name": "NIX 👨‍👩‍👧‍👦/🐣",
                "int": 18,
                "mastodon": {
                    "profile": {
                        "username": "@nixzhu@mastodon.social",
                        "nickname": "NIX",
                        "avatar_url": "https://files.mastodon.social/accounts/avatars/109/329/064/034/222/219/original/371901c6daa01207.png",
                        "mp3_url": "https://freetyst.nf.migu.cn/public/product9th/product45/2022/07/2210/2009年06月26日博尔普斯/标清高清/MP3_320_16_Stero/60054701923104030.mp3",
                        "extra_info": {},
                        "extra_list": []
                    },
                    "toots": [
                        {
                            "id": 1,
                            "content": "Hello World!",
                            "is_protected": false,
                            "created_at": "1234567890"
                        },
                        {
                            "id": 2,
                            "content": "How do you do?",
                            "is_protected": "true",
                            "created_at": 1234567890
                        },
                        {
                            "id": "88888888888888888",
                            "content": "A4纸不发货了",
                            "is_protected": 0,
                            "created_at": "8888888888"
                        },
                        {
                            "id": "99999999999999999",
                            "content": "春季快乐！",
                            "is_protected": 1,
                            "created_at": "2012-04-23T18:25:43.511Z"
                        }
                    ]
                }
            }
            """

        let model = User(jsonString)

        XCTAssertEqual(model.id, 42)
        XCTAssertEqual(model.name, "NIX 👨‍👩‍👧‍👦/🐣")
        XCTAssertEqual(model.int, 18)
        XCTAssertEqual(model.mastodon.profile.username, "@nixzhu@mastodon.social")

        XCTAssertEqual(
            model.mastodon.profile.avatarURL.absoluteString,
            "https://files.mastodon.social/accounts/avatars/109/329/064/034/222/219/original/371901c6daa01207.png"
        )
        XCTAssertEqual(
            model.mastodon.profile.mp3URL.absoluteString,
            "https://freetyst.nf.migu.cn/public/product9th/product45/2022/07/2210/2009%E5%B9%B406%E6%9C%8826%E6%97%A5%E5%8D%9A%E5%B0%94%E6%99%AE%E6%96%AF/%E6%A0%87%E6%B8%85%E9%AB%98%E6%B8%85/MP3_320_16_Stero/60054701923104030.mp3"
        )

        XCTAssertEqual(model.mastodon.toots[0].isProtected, false)
        XCTAssertEqual(model.mastodon.toots[0].id, 1)

        XCTAssertEqual(
            model.mastodon.toots[0].createdAt,
            .init(timeIntervalSince1970: 1_234_567_890)
        )

        XCTAssertEqual(model.mastodon.toots[1].isProtected, true)
        XCTAssertEqual(model.mastodon.toots[1].id, 2)

        XCTAssertEqual(
            model.mastodon.toots[1].createdAt,
            .init(timeIntervalSince1970: 1_234_567_890)
        )

        XCTAssertEqual(model.mastodon.toots[2].isProtected, false)
        XCTAssertEqual(model.mastodon.toots[2].id, 88_888_888_888_888_888)

        XCTAssertEqual(
            model.mastodon.toots[2].createdAt,
            .init(timeIntervalSince1970: 8_888_888_888)
        )

        XCTAssertEqual(model.mastodon.toots[3].isProtected, true)
        XCTAssertEqual(model.mastodon.toots[3].id, 99_999_999_999_999_999)

        XCTAssertEqual(
            model.mastodon.toots[3].createdAt.timeIntervalSince1970,
            1_335_205_543.511
        )
    }

    func testArray() {
        struct Model: AnandaModel {
            let list: [Item]

            init(json: AnandaJSON) {
                list = json.array().map { .init(json: $0) }
            }
        }

        struct Item: AnandaModel {
            let id: Int
            let name: String

            init(json: AnandaJSON) {
                id = json.id.int()
                name = json.name.string()
            }
        }

        let jsonData = """
            [
                {
                    "id": 0,
                    "name": "nix"
                },
                {
                    "id": 1,
                    "name": "zhu"
                }
            ]
            """.data(using: .utf8)!

        let model = Model(jsonData)
        XCTAssertEqual(model.list[0].id, 0)
        XCTAssertEqual(model.list[0].name, "nix")
        XCTAssertEqual(model.list[1].id, 1)
        XCTAssertEqual(model.list[1].name, "zhu")
    }
}
