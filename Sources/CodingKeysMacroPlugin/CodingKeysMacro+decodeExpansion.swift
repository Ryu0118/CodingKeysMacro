import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension CodingKeysMacro {
    static func decodeExpansion(
        of attribute: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) -> (CodingKeysOption, StructDeclSyntax)? {
        guard case let .argumentList(arguments) = attribute.argument,
              let firstElement = arguments.first?.expression
        else {
            context.diagnose(CodingKeysMacroDiagnostic.noArgument.diagnose(at: attribute))
            return nil
        }

        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            context.diagnose(CodingKeysMacroDiagnostic.requiresStruct.diagnose(at: attribute))
            return nil
        }

        if let memberAccessExpr = firstElement.as(MemberAccessExprSyntax.self),
           let option = decodeMemberAccess(of: attribute, expr: memberAccessExpr, in: context)
        {
            return (option, structDecl)
        }
        else if let functionCallExpr = firstElement.as(FunctionCallExprSyntax.self),
                let option = decodeFunctionCall(of: attribute, expr: functionCallExpr, in: context)
        {
            return (option, structDecl)
        }
        else {
            context.diagnose(CodingKeysMacroDiagnostic.invalidArgument.diagnose(at: attribute))
            return nil
        }
    }

    private static func decodeMemberAccess(
        of attribute: AttributeSyntax,
        expr memberAccessExpr: MemberAccessExprSyntax,
        in context: some MacroExpansionContext
    ) -> CodingKeysOption? {
        if memberAccessExpr.name.trimmedDescription == "all"
        {
            return .all
        } else {
            context.diagnose(CodingKeysMacroDiagnostic.noArgument.diagnose(at: attribute))
            return nil
        }
    }

    private static func decodeFunctionCall(
        of attribute: AttributeSyntax,
        expr functionCallExpr: FunctionCallExprSyntax,
        in context: some MacroExpansionContext
    ) -> CodingKeysOption? {
        guard let caseName = functionCallExpr.calledExpression.as(MemberAccessExprSyntax.self)?.name.text,
              let expression = functionCallExpr.argumentList.first?.expression else
        {
            context.diagnose(CodingKeysMacroDiagnostic.noArgument.diagnose(at: attribute))
            return nil
        }

        if let arrayExpr = expression.as(ArrayExprSyntax.self),
           let stringArray = arrayExpr.stringArray
        {
            return .associatedValueArray(caseName, associatedValue: stringArray)
        }
        else if let dictionaryElements = expression.as(DictionaryExprSyntax.self),
                let stringDictionary = dictionaryElements.stringDictionary
        {
            return .associatedValueDictionary(caseName, associatedValue: stringDictionary)
        }
        else {
            context.diagnose(CodingKeysMacroDiagnostic.invalidArgument.diagnose(at: attribute))
            return nil
        }
    }
}

fileprivate extension ArrayExprSyntax {
    var stringArray: [String]? {
        elements.reduce(into: [String]()) { result, element in
            guard let string = element.expression.as(StringLiteralExprSyntax.self) else {
                return
            }
            result.append(string.rawValue)
        }
    }
}

fileprivate extension StringLiteralExprSyntax {
    var rawValue: String {
        segments
            .compactMap { $0.as(StringSegmentSyntax.self) }
            .map(\.content.text)
            .joined()
    }
}

fileprivate extension DictionaryExprSyntax {
    var stringDictionary: [String: String]? {
        guard let elements = content.as(DictionaryElementListSyntax.self) else {
            return nil
        }

        return elements.reduce(into: [String: String]()) { result, element in
            guard let key = element.keyExpression.as(StringLiteralExprSyntax.self),
                  let value = element.valueExpression.as(StringLiteralExprSyntax.self)
            else {
                return
            }
            result.updateValue(value.rawValue, forKey: key.rawValue)
        }
    }
}
