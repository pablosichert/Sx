import func Sx.compare
import func XCTest.XCTAssertEqual
import class XCTest.XCTestCase

// swiftlint:disable:next type_name
class compareTest: XCTestCase {
    func testFunctionIdempodent() {
        func foo() {}

        XCTAssertEqual(compare(foo, foo), true)
    }

    func testFunctionSameReference() {
        func foo() {}
        let bar = foo

        XCTAssertEqual(compare(foo, bar), true)
    }

    func testFunctionDifferent() {
        func foo() {}
        func bar() {}

        XCTAssertEqual(compare(foo, bar), false)
    }

    func testClosureIdempodent() {
        let foo = {}

        XCTAssertEqual(compare(foo, foo), true)
    }

    func testClosureSameReference() {
        let foo = {}
        let bar = foo

        XCTAssertEqual(compare(foo, bar), true)
    }

    func testClosureDifferent() {
        let foo = {}
        let bar = {}

        XCTAssertEqual(compare(foo, bar), false)
    }

    func testInstanceMethodIdempodent() {
        class Foo {
            func foo() {}
        }

        let foo = Foo()

        XCTAssertEqual(compare(foo.foo, foo.foo), true)
    }

    func testInstanceMethodSameReference() {
        class Foo {
            func foo() {}
        }

        let foo = Foo().foo
        let bar = foo

        XCTAssertEqual(compare(foo, bar), true)
    }

    func testInstanceMethodDifferent() {
        class Foo {
            func foo() {}
        }

        let foo = Foo().foo
        let bar = Foo().foo

        XCTAssertEqual(compare(foo, bar), false)
    }
}
