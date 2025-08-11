/// A type that represents a path item in a JSON structure.
public enum AnandaPathItem: ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
    /// A dictionary key.
    case key(String)

    /// An array index.
    case index(Int)

    public init(stringLiteral value: String) {
        self = .key(value)
    }

    public init(integerLiteral value: Int) {
        self = .index(value)
    }
}
