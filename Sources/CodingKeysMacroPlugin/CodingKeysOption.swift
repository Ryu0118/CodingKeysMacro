public enum CodingKeysOption {
    case all
    case select([String])
    case exclude([String])
    case custom([String: String])

    var necessaryProperties: [String] {
        switch self {
        case .all:
            []
        case .select(let array), .exclude(let array):
            array
        case .custom(let dictionary):
            .init(dictionary.keys)
        }
    }

    static func associatedValueArray(
        _ caseName: String,
        associatedValue: [String]
    ) -> Self? {
        switch caseName {
        case "select":
            return .select(associatedValue)

        case "exclude":
            return .exclude(associatedValue)

        default:
            return nil
        }
    }

    static func associatedValueDictionary(
        _ caseName: String,
        associatedValue: [String: String]
    ) -> Self? {
        if caseName == "custom" {
            return .custom(associatedValue)
        } else {
            return nil
        }
    }
}
