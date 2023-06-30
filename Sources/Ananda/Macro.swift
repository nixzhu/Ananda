@attached(member, names: named(init(json:)))
public macro AnandaInit() = #externalMacro(
    module: "AnandaMacros",
    type: "AnandaInitMacro"
)
