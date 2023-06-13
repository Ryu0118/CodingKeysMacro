#if canImport(SwiftCompilerPlugin)
import SwiftSyntaxMacros
import SwiftCompilerPlugin

@main
struct CodingKeysMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CodingKeysMacro.self
    ]
}
#endif
