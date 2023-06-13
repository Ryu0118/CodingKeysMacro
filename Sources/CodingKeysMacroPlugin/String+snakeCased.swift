extension String {
    func snakeCased() -> Self {
        var snakeCaseString = ""
        for char in self {
            if char.isUppercase {
                snakeCaseString += "_" + char.lowercased()
            } else {
                snakeCaseString += String(char)
            }
        }
        return snakeCaseString
    }
}
