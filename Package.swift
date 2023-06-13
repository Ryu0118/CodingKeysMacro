// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "CodingKeysMacro",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_15),
        .tvOS(.v11),
        .watchOS(.v4)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CodingKeysMacro",
            targets: ["CodingKeysMacro"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CodingKeysMacro",
            dependencies: [
                "CodingKeysMacroPlugin"
            ]
        ),
        .macro(
            name: "CodingKeysMacroPlugin",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "CodingKeysMacroTests",
            dependencies: [
                "CodingKeysMacro",
                "CodingKeysMacroPlugin",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        ),
    ]
)
