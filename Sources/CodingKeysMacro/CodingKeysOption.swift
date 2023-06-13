public enum CodingKeysOption {
    case all
    case select([String])
    case exclude([String])
    case custom([String: String])
}
