import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct AnandaPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AnandaInitMacro.self,
        AnandaKeyMacro.self,
        AnandaIgnoredMacro.self,
    ]
}
