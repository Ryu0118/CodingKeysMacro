import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
@testable import CodingKeysMacro
@testable import CodingKeysMacroPlugin

final class CodingKeysMacroTests: XCTestCase {
    let macros: [String: Macro.Type] = [
        "CodingKeysMacro": CodingKeysMacro.self
    ]

    func testOptionAll() throws {
        assertMacroExpansion(
            """
            @CodingKeysMacro(.all)
            public struct Hoge {
                let hogeHoge: String
                let fugaFuga: String
                let hoge: String
                let fuga: String
            }
            """,
            expandedSource: """

            public struct Hoge {
                let hogeHoge: String
                let fugaFuga: String
                let hoge: String
                let fuga: String
                enum CodingKeys: String, CodingKey {
                    case hogeHoge = "hoge_hoge"
                    case fugaFuga = "fuga_fuga"
                    case hoge
                    case fuga
                }
            }
            """,
            macros: macros
        )
    }

    func testOptionSelect() throws {
        assertMacroExpansion(
            """
            @CodingKeysMacro(.select(["hogeHoge", "hoge"])
            public struct Hoge {
                let hogeHoge: String
                var fugaFuga: String
                let hoge: String
                var fuga: String
            }
            """
            ,
            expandedSource: """

            public struct Hoge {
                let hogeHoge: String
                var fugaFuga: String
                let hoge: String
                var fuga: String
                enum CodingKeys: String, CodingKey {
                    case hogeHoge = "hoge_hoge"
                    case fugaFuga
                    case hoge
                    case fuga
                }
            }
            """,
            macros: macros
        )
    }

    func testOptionExclude() throws {
        assertMacroExpansion(
            """
            @CodingKeysMacro(.exclude(["hogeHoge", "fooFoo"])
            public struct Hoge {
                let hogeHoge: String
                var fugaFuga: String
                let fooFoo: String
                var hogeHogeHoge: String
            }
            """
            ,
            expandedSource: """

            public struct Hoge {
                let hogeHoge: String
                var fugaFuga: String
                let fooFoo: String
                var hogeHogeHoge: String
                enum CodingKeys: String, CodingKey {
                    case hogeHoge
                    case fugaFuga = "fuga_fuga"
                    case fooFoo
                    case hogeHogeHoge = "hoge_hoge_hoge"
                }
            }
            """,
            macros: macros
        )
    }

    func testOptionCustom() throws {
        assertMacroExpansion(
            """
            @CodingKeysMacro(.custom(["id": "hoge_id", "hogeHoge": "hogee"])
            public struct Hoge {
                let id: String
                let hogeHoge: String
                var fugaFuga: String
                let fooFoo: String
                var hogeHogeHoge: String
            }
            """
            ,
            expandedSource: """

            public struct Hoge {
                let id: String
                let hogeHoge: String
                var fugaFuga: String
                let fooFoo: String
                var hogeHogeHoge: String
                enum CodingKeys: String, CodingKey {
                    case id = "hoge_id"
                    case hogeHoge = "hogee"
                    case fugaFuga = "fuga_fuga"
                    case fooFoo = "foo_foo"
                    case hogeHogeHoge = "hoge_hoge_hoge"
                }
            }
            """,
            macros: macros
        )
    }
}
