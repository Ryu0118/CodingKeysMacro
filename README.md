# CodingKeysMacro
Swift Macro that automatically generates CodingKeys for converting snake_case to lowerCamelCase.

## Installation
```Swift
.package(url: "https://github.com/Ryu0118/CodingKeysMacro", branch: "main")
```
## Usage
### .all
```Swift
@CodingKeys(.all)
struct UserResponse: Codable {
    let id: String
    let age: Int
    let userName: String
    let userDescription: String
}
// expanded to...
struct UserResponse: Codable {
    ...
    enum CodingKeys: String, CodingKey {
        case id
        case age
        case userName = "user_name"
        case userDescription = "user_description"
    }
}
```
### .select
```Swift
@CodingKeys(.select(["userName"]))
struct UserResponse: Codable {
    let id: String
    let age: Int
    let userName: String
    let userDescription: String
}
// expanded to...
struct UserResponse: Codable {
    ...
    enum CodingKeys: String, CodingKey {
        case id
        case age
        case userName = "user_name"
        case userDescription
    }
}
```
### .exclude
```Swift
@CodingKeys(.exclude(["userName", "userDescription"]))
struct UserResponse: Codable {
    let id: String
    let age: Int
    let userName: String
    let userDescription: String
}
// expanded to...
struct UserResponse: Codable {
    ...
    enum CodingKeys: String, CodingKey {
        case id
        case age
        case userName
        case userDescription
    }
}
```
### .custom
```Swift
@CodingKeys(.custom(["id", "user_id"]))
struct UserResponse: Codable {
    let id: String
    let age: Int
    let userName: String
    let userDescription: String
}
// expanded to...
struct UserResponse: Codable {
    ...
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case age
        case userName = "user_name"
        case userDescription = "user_description"
    }
}
```

