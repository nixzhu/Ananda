import XCTest
@testable import Ananda

final class AnandaTests: XCTestCase {
    func testBool() {
        struct Model: AnandaModel {
            let boolA: Bool
            let boolB: Bool
            let boolC: Bool
            let boolD: Bool
            let boolE: Bool
            let boolF: Bool
            let boolG: Bool
            let boolH: Bool
            let boolI: Bool

            init(json: AnandaJSON) {
                boolA = json.boolA.bool()
                boolB = json.boolB.bool()
                boolC = json.boolC.bool()
                boolD = json.boolD.bool()
                boolE = json.boolE.bool()
                boolF = json.boolF.bool()
                boolG = json.boolG.bool()
                boolH = json.boolH.bool()
                boolI = json.boolI.bool()
            }
        }

        let jsonString = """
            {
                "boolA": true,
                "boolB": false,
                "boolC": 0,
                "boolD": 1,
                "boolE": -1,
                "boolF": 100,
                "boolG": "true",
                "boolH": "false",
                "boolI": ""
            }
            """

        let model = Model(jsonString: jsonString)
        XCTAssertEqual(model.boolA, true)
        XCTAssertEqual(model.boolB, false)
        XCTAssertEqual(model.boolC, false)
        XCTAssertEqual(model.boolD, true)
        XCTAssertEqual(model.boolE, true)
        XCTAssertEqual(model.boolF, true)
        XCTAssertEqual(model.boolG, false)
        XCTAssertEqual(model.boolH, false)
        XCTAssertEqual(model.boolI, false)
    }

    func testInt() {
        struct Model: AnandaModel {
            let intA: Int
            let intB: Int
            let intC: Int
            let intD: Int
            let intE: Int
            let intF: Int
            let intG: Int
            let intH: Int
            let intI: Int

            init(json: AnandaJSON) {
                intA = json.intA.int()
                intB = json.intB.int()
                intC = json.intC.int()
                intD = json.intD.int()
                intE = json.intE.int()
                intF = json.intF.int()
                intG = json.intG.int()
                intH = json.intH.int()
                intI = json.intI.int()
            }
        }

        let jsonString = """
            {
                "intA": -1,
                "intB": 0,
                "intC": 1,
                "intD": "-1",
                "intE": "0",
                "intF": "1",
                "intG": "",
                "intH": "1.2",
                "intI": 4.5
            }
            """

        let model = Model(jsonString: jsonString)
        XCTAssertEqual(model.intA, -1)
        XCTAssertEqual(model.intB, 0)
        XCTAssertEqual(model.intC, 1)
        XCTAssertEqual(model.intD, -1)
        XCTAssertEqual(model.intE, 0)
        XCTAssertEqual(model.intF, 1)
        XCTAssertEqual(model.intG, 0)
        XCTAssertEqual(model.intH, 0)
        XCTAssertEqual(model.intI, 0)
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

        let model = User(jsonString: jsonString)

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

        let model = Model(jsonData: jsonData)
        XCTAssertEqual(model.list[0].id, 0)
        XCTAssertEqual(model.list[0].name, "nix")
        XCTAssertEqual(model.list[1].id, 1)
        XCTAssertEqual(model.list[1].name, "zhu")
    }
}
