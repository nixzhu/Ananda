@attached(member, names: named(init(json:)))
public macro AnandaInit() = #externalMacro(
    module: "AnandaMacros",
    type: "AnandaInitMacro"
)

@attached(member)
public macro AnandaKey(_: String) = #externalMacro(
    module: "AnandaMacros",
    type: "AnandaKeyMacro"
)
