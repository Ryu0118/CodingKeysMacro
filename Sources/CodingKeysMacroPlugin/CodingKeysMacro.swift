import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct CodingKeysMacro: MemberMacro {
    public static func expansion<
        Declaration: DeclGroupSyntax, Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard let (option, structDecl) = decodeExpansion(of: node, attachedTo: declaration, in: context) else {
            return []
        }

        let properties = getProperties(decl: structDecl)

        guard diagnoseInvalidProperties(
            option: option,
            properties: properties,
            structName: structDecl.identifier.text,
            declaration: declaration,
            in: context
        ) else {
            return []
        }

        let generator = CodingKeysGenerator(option: option, properties: properties)

        let decl = generator
            .generate()
            .formatted()
            .as(EnumDeclSyntax.self)!

        return [
            DeclSyntax(decl)
        ]
    }

    private static func getProperties(decl: StructDeclSyntax) -> [String] {
        var properties = [String]()

        for decl in decl.memberBlock.members.map(\.decl) {
            if let variableDecl = decl.as(VariableDeclSyntax.self) {
                properties.append(
                    contentsOf: variableDecl.bindings.compactMap { $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text }
                )
            }
        }

        return properties
    }

    private static func diagnoseInvalidProperties(
        option: CodingKeysOption,
        properties: [String],
        structName: String,
        declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) -> Bool {
        let invalidProperties = option.necessaryProperties.compactMap {
            if !properties.contains($0) {
                return $0
            } else {
                return nil
            }
        }

        if !invalidProperties.isEmpty {
            context.diagnose(
                CodingKeysMacroDiagnostic.nonexistentProperty(
                    structName: structName,
                    propertyName: invalidProperties.joined(separator: ", ")
                )
                .diagnose(at: declaration)
            )
        }

        return invalidProperties.isEmpty
    }
}
