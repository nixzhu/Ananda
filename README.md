# Ananda

JSON model decoding based on [yyjson](https://github.com/ibireme/yyjson).

## Example

We have JSON as follow:

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

And we create models conforms to `AnandaModel` protocol as follow:

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

Then, we can initialize a `Mastodon` as follow:

```swift
let model = Mastodon.decode(from: jsonString)
```

Or

```swift
let model = Mastodon.decode(from: jsonData)
```

## Swift Macro

With Swift 5.9, you can use macro to eliminate the initialization methods as follow:

```swift
import Foundation
import Ananda

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

You may use [Ducky Model Editor](https://apps.apple.com/us/app/ducky-model-editor/id1525505933) to generate AnandaModel from JSON to save your time.

![Ducky Model Editor](https://raw.githubusercontent.com/nixzhu/Ananda/main/ducky-model-editor-ananda.png)

![Ducky Model Editor](https://raw.githubusercontent.com/nixzhu/Ananda/main/ducky-model-editor-ananda-macros.png)
