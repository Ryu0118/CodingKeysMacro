import SwiftSyntax
import SwiftDiagnostics

public enum CodingKeysMacroDiagnostic {
    case nonexistentProperty(structName: String, propertyName: String)
    case noArgument
    case requiresStruct
    case invalidArgument
}

extension CodingKeysMacroDiagnostic: DiagnosticMessage {
    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }

    public var message: String {
        switch self {
        case let .nonexistentProperty(structName, propertyName):
            return "Property \(propertyName) does not exist in \(structName)"

        case .noArgument:
            return "Cannot find argument"

        case .requiresStruct:
            return "'CodingKeys' macro can only be applied to struct."

        case .invalidArgument:
            return "Invalid Argument"
        }
    }

    public var severity: DiagnosticSeverity { .error }

    public var diagnosticID: MessageID {
        MessageID(domain: "Swift", id: "CodingKeysMacro.\(self)")
    }
}
