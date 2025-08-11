[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnixzhu%2FAnanda%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/nixzhu/Ananda) 
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnixzhu%2FAnanda%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/nixzhu/Ananda)

# Ananda

JSON model decoding based on [yyjson](https://github.com/ibireme/yyjson).

## Example

Consider the following JSON:

```json
{
    "profile": {
        "nickname": "NIX",
        "username": "@nixzhu@mastodon.social",
        "avatar": {
            "url": "https://example.com/nixzhu.png",
            "width": 200,
            "height": 200
        }
    },
    "toots": [
        {
            "id": 1,
            "content": "Hello World!",
            "created_at": "2024-10-05T09:41:00.789Z"
        },
        {
            "id": 2,
            "content": "How do you do?",
            "created_at": "2025-04-29T22:23:24.567Z"
        }
    ]
}
```

We can create models conforming to the `AnandaModel` protocol as follows:

```swift
import Foundation
import Ananda

struct Mastodon: AnandaModel {
    let profile: Profile
    let toots: [Toot]

    init(json: AnandaJSON) {
        profile = .decode(from: json.profile)
        toots = json.toots.array().map { .decode(from: $0) }
    }
}

extension Mastodon {
    struct Profile: AnandaModel {
        let nickname: String
        let username: String
        let avatar: Avatar

        init(json: AnandaJSON) {
            nickname = json.nickname.string()
            username = json.username.string()
            avatar = .decode(from: json.avatar)
        }
    }
}

extension Mastodon.Profile {
    struct Avatar: AnandaModel {
        let url: URL
        let width: Double
        let height: Double

        init(json: AnandaJSON) {
            url = json["url"].url()
            width = json.width.double()
            height = json.height.double()
        }
    }
}

extension Mastodon {
    struct Toot: AnandaModel {
        let id: Int
        let content: String
        let createdAt: Date

        init(json: AnandaJSON) {
            id = json.id.int()
            content = json.content.string()
            createdAt = json.created_at.date()
        }
    }
}
```

To decode a `Mastodon` instance from a JSON string:

```swift
let mastodon = Mastodon.decode(from: jsonString)
```

Or, if you already have JSON data:

```swift
let mastodon = Mastodon.decode(from: jsonData)
```

To decode a specific JSON branch, for example `profile.avatar`, specify its path:

```swift
let avatar = Mastodon.Profile.Avatar.decode(from: jsonData, path: ["profile", "avatar"])
```

To decode an array (e.g., `toots`):

```swift
let toots = [Mastodon.Toot].decode(from: jsonData, path: ["toots"])
```

Or decode only the first toot:

```swift
let toot = Mastodon.Toot.decode(from: jsonData, path: ["toots", 0])
```

## Swift Macro

With [AnandaMacros](https://github.com/nixzhu/AnandaMacros), you can use macros to eliminate the need for initialization methods, as shown below:

```swift
import Foundation
import Ananda
import AnandaMacros

@AnandaInit
struct Mastodon: AnandaModel {
    let profile: Profile
    let toots: [Toot]
}

extension Mastodon {
    @AnandaInit
    struct Profile: AnandaModel {
        let nickname: String
        let username: String
        let avatar: Avatar
    }
}

extension Mastodon.Profile {
    @AnandaInit
    struct Avatar: AnandaModel {
        let url: URL
        let width: Double
        let height: Double
    }
}

extension Mastodon {
    @AnandaInit
    struct Toot: AnandaModel {
        let id: Int
        let content: String
        @AnandaKey("created_at")
        let createdAt: Date
    }
}
```

Simple and clean, right?

## Benchmark

See [AnandaBenchmark](https://github.com/nixzhu/AnandaBenchmark).

## Tool

You can use [Ducky Model Editor](https://apps.apple.com/us/app/ducky-model-editor/id1525505933) to generate AnandaModel from JSON, saving you time.

![Ducky Model Editor](https://raw.githubusercontent.com/nixzhu/Ananda/main/images/ducky-ananda.png)

![Ducky Model Editor](https://raw.githubusercontent.com/nixzhu/Ananda/main/images/ducky-ananda-macros.png)
