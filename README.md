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
            createdAt = json.created_at.unixDate()
        }
    }
}
```

Then, we can initialize a `Mastodon` as follow:

```swift
let model = Mastodon(jsonString: jsonString)
```
