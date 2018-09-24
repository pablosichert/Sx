import func Sx.compare
import func XCTest.XCTAssert
import class XCTest.XCTestCase

// swiftlint:disable:next type_name
class compareTest: XCTestCase {
    func testFunctionIdempodent() {
        func foo() {}

        XCTAssert(compare(foo, foo))
    }

    func testFunctionSameReference() {
        func foo() {}
        let bar = foo

        XCTAssert(compare(foo, bar))
    }

    func testFunctionDifferent() {
        func foo() {}
        func bar() {}

        XCTAssert(!compare(foo, bar))
    }

    func testClosureIdempodent() {
        let foo = {}

        XCTAssert(compare(foo, foo))
    }

    func testClosureSameReference() {
        let foo = {}
        let bar = foo

        XCTAssert(compare(foo, bar))
    }

    func testClosureDifferent() {
        let foo = {}
        let bar = {}

        XCTAssert(!compare(foo, bar))
    }

    func testInstanceMethodIdempodent() {
        class Foo {
            func foo() {}
        }

        let foo = Foo()

        XCTAssert(compare(foo.foo, foo.foo))
    }

    func testInstanceMethodSameReference() {
        class Foo {
            func foo() {}
        }

        let foo = Foo().foo
        let bar = foo

        XCTAssert(compare(foo, bar))
    }

    func testInstanceMethodDifferent() {
        class Foo {
            func foo() {}
        }

        let foo = Foo().foo
        let bar = Foo().foo

        XCTAssert(!compare(foo, bar))
    }
}
