import SwiftSyntax
import SwiftSyntaxBuilder

struct CodingKeysGenerator {
    enum CodingKeysStrategy {
        case equal(String, String)
        case skip(String)

        func enumCaseElementSyntax() -> EnumCaseElementSyntax {
            switch self {
            case .equal(let caseName, let value):
                EnumCaseElementSyntax(
                    identifier: .identifier(caseName),
                    rawValue: InitializerClauseSyntax(
                        equal: .equalToken(),
                        value: StringLiteralExprSyntax(content: value)
                    )
                )
            case .skip(let caseName):
                EnumCaseElementSyntax(identifier: .identifier(caseName))
            }
        }
    }

    let option: CodingKeysOption
    let properties: [String]

    init(option: CodingKeysOption, properties: [String]) {
        self.option = option
        self.properties = properties
    }

    func generate() -> EnumDeclSyntax {
        EnumDeclSyntax(
            identifier: .identifier("CodingKeys"),
            inheritanceClause: TypeInheritanceClauseSyntax {
                InheritedTypeSyntax(typeName: TypeSyntax(stringLiteral: "String"))
                InheritedTypeSyntax(typeName: TypeSyntax(stringLiteral: "CodingKey"))
            }
        ) {
            MemberDeclListSyntax(
                generateStrategy().map { strategy in
                    MemberDeclListItemSyntax(
                        decl: EnumCaseDeclSyntax(
                            elements: EnumCaseElementListSyntax(
                                arrayLiteral: strategy.enumCaseElementSyntax()
                            )
                        )
                    )
                }
            )
        }
    }

    private func generateStrategy() -> [CodingKeysStrategy] {
        properties.map {
            switch option {
            case .all:
                return .equal($0, $0.snakeCased())
            case let .select(selectedProperties):
                if selectedProperties.contains($0) {
                    return .equal($0, $0.snakeCased())
                } else {
                    return .skip($0)
                }
            case let .exclude(excludedProperties):
                if excludedProperties.contains($0) {
                    return .skip($0)
                } else {
                    return .equal($0, $0.snakeCased())
                }
            case let .custom(customNamePair):
                if customNamePair.map(\.key).contains($0),
                   let value = customNamePair[$0]
                {
                    return .equal($0, value)
                } else {
                    return .equal($0, $0.snakeCased())
                }
            }
        }
        .map { (strategy: CodingKeysStrategy) in
            switch strategy {
            case let .equal(key, value):
                if key == value {
                    return .skip(key)
                }
            default: break
            }
            return strategy
        }
    }
}
