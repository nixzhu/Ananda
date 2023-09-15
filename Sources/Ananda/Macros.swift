@attached(member, names: named(init(json:)))
public macro AnandaInit() = #externalMacro(
    module: "AnandaMacros",
    type: "AnandaInitMacro"
)

@attached(peer)
public macro AnandaKey(_: String) = #externalMacro(
    module: "AnandaMacros",
    type: "AnandaKeyMacro"
)

@attached(peer)
public macro AnandaIgnored() = #externalMacro(
    module: "AnandaMacros",
    type: "AnandaIgnoredMacro"
)
