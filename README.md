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
    "avatar_url": "https://files.mastodon.social/accounts/avatars/109/329/064/034/222/219/original/371901c6daa01207.png"
  },
  "toots": [
    {
      "id": 1,
      "content": "Hello World!",
      "created_at": "1674127714"
    },
    {
      "id": 2,
      "content": "How do you do?",
      "created_at": "1674127720"
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
        profile = .init(json: json.profile)
        toots = json.toots.array().map { .init(json: $0) }
    }
}

extension Mastodon {
    struct Profile: AnandaModel {
        let nickname: String
        let username: String
        let avatarURL: URL

        init(json: AnandaJSON) {
            username = json.username.string()
            nickname = json.nickname.string()
            avatarURL = json.avatar_url.url()
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

To decode a `Mastodon` instance, use the following code:

```swift
let mastodon = Mastodon.decode(from: jsonString)
```

Or

```swift
let mastodon = Mastodon.decode(from: jsonData)
```

If you only want to decode a specific part of the JSON, such as `profile`, specify the `path` as follows:

```swift
let profile = Mastodon.Profile.decode(from: jsonData, path: ["profile"])
```

To decode an array of `toots`, use the following code:

```swift
let toots = [Mastodon.Toot].decode(from: jsonData, path: ["toots"])
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
        @AnandaKey("avatar_url")
        let avatarURL: URL
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
