import struct Sx.Function
import func XCTest.XCTAssertEqual
import class XCTest.XCTestCase

private func == <Arguments, Return>(
    _ lhs: @escaping (Arguments) -> Return,
    _ rhs: @escaping (Arguments) -> Return
) -> Bool {
    return Function.from(lhs) == Function.from(rhs)
}

class FunctionTest: XCTestCase {
    func testFunctionIdempodent() {
        func foo() {}

        XCTAssertEqual(foo == foo, true)
    }

    func testFunctionSameReference() {
        func foo() {}
        let bar = foo

        XCTAssertEqual(foo == bar, true)
    }

    func testFunctionDifferent() {
        func foo() {}
        func bar() {}

        XCTAssertEqual(foo == bar, false)
    }

    func testClosureIdempodent() {
        let foo = {}

        XCTAssertEqual(foo == foo, true)
    }

    func testClosureSameReference() {
        let foo = {}
        let bar = foo

        XCTAssertEqual(foo == bar, true)
    }

    func testClosureDifferent() {
        let foo = {}
        let bar = {}

        XCTAssertEqual(foo == bar, false)
    }

    func testInstanceMethodIdempodent() {
        class Foo {
            func foo() {}
        }

        let foo = Foo()

        XCTAssertEqual(foo.foo == foo.foo, true)
    }

    func testInstanceMethodSameReference() {
        class Foo {
            func foo() {}
        }

        let foo = Foo().foo
        let bar = foo

        XCTAssertEqual(foo == bar, true)
    }

    func testInstanceMethodDifferent() {
        class Foo {
            func foo() {}
        }

        let foo = Foo().foo
        let bar = Foo().foo

        XCTAssertEqual(foo == bar, false)
    }
}
