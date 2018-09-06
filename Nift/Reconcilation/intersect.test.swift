import func Reconcilation.intersect
import func XCTest.XCTAssert
import class XCTest.XCTestCase

// swiftlint:disable:next type_name
class intersectTest: XCTestCase {
    func testOverlappingRanges() {
        let a = 0 ..< 3
        let b = 0 ..< 3

        let intersection = intersect(a, b)

        XCTAssert(intersection?.count == 3)
        XCTAssert(intersection?.lowerBound == 0)
        XCTAssert(intersection?.upperBound == 3)
    }

    func testBContinuingA() {
        let a = 0 ..< 3
        let b = 3 ..< 6

        let intersection = intersect(a, b)

        XCTAssert(intersection == nil)
    }

    func testAContinuingB() {
        let a = 3 ..< 6
        let b = 0 ..< 3

        let intersection = intersect(a, b)

        XCTAssert(intersection == nil)
    }

    func testBAfterA() {
        let a = 0 ..< 10
        let b = 100 ..< 1000

        let intersection = intersect(a, b)

        XCTAssert(intersection == nil)
    }

    func testAAfterB() {
        let a = 100 ..< 1000
        let b = 0 ..< 10

        let intersection = intersect(a, b)

        XCTAssert(intersection == nil)
    }

    func testBPartiallyOverlappingA() {
        let a = 0 ..< 10
        let b = 5 ..< 15

        let intersection = intersect(a, b)

        XCTAssert(intersection?.count == 5)
        XCTAssert(intersection?.lowerBound == 5)
        XCTAssert(intersection?.upperBound == 10)
    }

    func testAPartiallyOverlappingB() {
        let a = 5 ..< 15
        let b = 0 ..< 10

        let intersection = intersect(a, b)

        XCTAssert(intersection?.count == 5)
        XCTAssert(intersection?.lowerBound == 5)
        XCTAssert(intersection?.upperBound == 10)
    }

    func testAIncludingB() {
        let a = 0 ..< 30
        let b = 10 ..< 20

        let intersection = intersect(a, b)

        XCTAssert(intersection?.count == 10)
        XCTAssert(intersection?.lowerBound == 10)
        XCTAssert(intersection?.upperBound == 20)
    }

    func testBIncludingA() {
        let a = 10 ..< 20
        let b = 0 ..< 30

        let intersection = intersect(a, b)

        XCTAssert(intersection?.count == 10)
        XCTAssert(intersection?.lowerBound == 10)
        XCTAssert(intersection?.upperBound == 20)
    }
}
