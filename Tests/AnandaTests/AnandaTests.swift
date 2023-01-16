import XCTest
@testable import Ananda

final class AnandaTests: XCTestCase {
    func testAnandaModel() throws {
        let jsonString = """
            {
                "id": 42,
                "name": "NIX 👨‍👩‍👧‍👦/🐣",
                "int": 18,
                "mastodon": {
                    "profile": {
                        "username": "@nixzhu@mastodon.social",
                        "nickname": "NIX",
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
                            "is_protected": false,
                            "created_at": 1234567890
                        },
                        {
                            "id": "88888888888888888",
                            "content": "A4纸不发货了",
                            "is_protected": true,
                            "created_at": "9999999999"
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
            model.mastodon.toots[0].createdAt,
            .init(timeIntervalSince1970: 1_234_567_890)
        )

        XCTAssertEqual(
            model.mastodon.toots[1].createdAt,
            .init(timeIntervalSince1970: 1_234_567_890)
        )

        XCTAssertEqual(model.mastodon.toots[2].isProtected, true)
        XCTAssertEqual(model.mastodon.toots[2].id, 88_888_888_888_888_888)
    }
}

struct User: AnandaModel {
    let id: Int
    let name: String
    let int: Int
    let mastodon: Mastodon

    init(json: AnandaJSON) {
        id = json.id.int
        name = json.name.string
        int = json["int"].int
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

        let mastodon = json.mastodon.object
        assert(mastodon["profile"]?.username.string == "@nixzhu@mastodon.social")
    }
}

extension User {
    struct Mastodon: AnandaModel {
        let profile: Profile
        let toots: [Toot]

        init(json: AnandaJSON) {
            profile = .init(json: json.profile)
            toots = json.toots.array.map { .init(json: $0) }

            assert(json.toots[-1].id.int == 0)
            assert(json.toots[0].id.int == 1)
            assert(json.toots[1].id.int == 2)
            assert(json.toots[2].id.intOrString == 88_888_888_888_888_888)
            assert(json.toots[3].id.int == 0)
        }
    }
}

extension User.Mastodon {
    struct Toot: AnandaModel {
        let id: Int
        let content: String
        let isProtected: Bool
        let createdAt: Date

        init(json: AnandaJSON) {
            id = json.id.intOrString
            content = json.content.string
            isProtected = json.is_protected.bool
            createdAt = json.created_at.unixDate
        }
    }
}

extension User.Mastodon {
    struct Profile: AnandaModel {
        let username: String
        let nickname: String

        init(json: AnandaJSON) {
            username = json.username.string
            nickname = json.nickname.string
        }
    }
}
