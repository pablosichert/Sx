import class XCTest.XCTestCase
import func XCTest.XCTAssert
import func Nift.equal

private class Test: XCTestCase {
    func testFunctionIdempodent() {
        func foo() {}

        XCTAssert(equal(foo, foo))
    }

    func testFunctionSameReference() {
        func foo() {}
        let bar = foo

        XCTAssert(equal(foo, bar))
    }

    func testFunctionDifferent() {
        func foo() {}
        func bar() {}

        XCTAssert(!equal(foo, bar))
    }

    func testClosureIdempodent() {
        let foo = {}

        XCTAssert(equal(foo, foo))
    }

    func testClosureSameReference() {
        let foo = {}
        let bar = foo

        XCTAssert(equal(foo, bar))
    }

    func testClosureDifferent() {
        let foo = {}
        let bar = {}

        XCTAssert(!equal(foo, bar))
    }

    func testInstanceMethodIdempodent() {
        class Foo {
            func foo() {}
        }

        let foo = Foo()

        XCTAssert(equal(foo.foo, foo.foo))
    }

    func testInstanceMethodSameReference() {
        class Foo {
            func foo() {}
        }

        let foo = Foo().foo
        let bar = foo

        XCTAssert(equal(foo, bar))
    }

    func testInstanceMethodDifferent() {
        class Foo {
            func foo() {}
        }

        let foo = Foo().foo
        let bar = Foo().foo

        XCTAssert(!equal(foo, bar))
    }
}
