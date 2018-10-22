import struct Reconcilation.Equal
import func XCTest.XCTAssertEqual
import class XCTest.XCTestCase

class EqualTest: XCTestCase {
    func testCallABEqual() {
        let a = 123
        let b = 123

        XCTAssertEqual(Equal<Int>.call(a, b), true)
    }

    func testCallABDifferent() {
        let a = "foo"
        let b = "bar"

        XCTAssertEqual(Equal<String>.call(a, b), false)
    }

    func testCallADifferentType() {
        let a = "foo"
        let b = 123

        XCTAssertEqual(Equal<String>.call(a, b), false)
    }

    func testCallBDifferentType() {
        let a = 123
        let b = "foo"

        XCTAssertEqual(Equal<Int>.call(a, b), false)
    }

    func testCallABDifferentTypes() {
        let a = 123
        let b = 123

        XCTAssertEqual(Equal<String>.call(a, b), false)
    }
}
