@attached(member, names: named(CodingKeys))
public macro CodingKeys(_ type: CodingKeysOption) = #externalMacro(module: "CodingKeysMacroPlugin", type: "CodingKeysMacro")
