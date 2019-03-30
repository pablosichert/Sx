import struct Sx.Property
import func XCTest.XCTAssertEqual
import class XCTest.XCTestCase

private class SomeHashable: Hashable {
    static func == (lhs: SomeHashable, rhs: SomeHashable) -> Bool {
        return lhs.value == rhs.value
    }

    var value: String

    init(_ value: String) {
        self.value = value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

private class SomeEquatable: Equatable {
    static func == (lhs: SomeEquatable, rhs: SomeEquatable) -> Bool {
        guard let lhsValue = lhs.value as? String, let rhsValue = rhs.value as? String else {
            return false
        }

        return lhsValue == rhsValue
    }

    var value: Any

    init(_ value: Any) {
        self.value = value
    }
}

private class WithHashableProperty {
    var foo: SomeHashable

    init(_ foo: String) {
        self.foo = SomeHashable(foo)
    }
}

private class WithEquatableProperty {
    var foo: SomeEquatable = SomeEquatable("foo")
}

private class WithFunctionProperty {
    var foo: (Bool) -> Bool = { $0 }
    var bar: Bool = false
}

private class WithProperty {
    var foo: Any = "foo"
}

class PropertyTest: XCTestCase {
    func testHashablePropertyIdempodent() {
        let a = Property(\WithHashableProperty.foo, SomeHashable("foo"))

        XCTAssertEqual(a == a, true)
    }

    func testHashablePropertyEqual() {
        let a = Property(\WithHashableProperty.foo, SomeHashable("foo"))
        let b = Property(\WithHashableProperty.foo, SomeHashable("foo"))

        XCTAssertEqual(a == b, true)
    }

    func testHashablePropertyDifferent() {
        let a = Property(\WithHashableProperty.foo, SomeHashable("foo"))
        let b = Property(\WithHashableProperty.foo, SomeHashable("bar"))

        XCTAssertEqual(a == b, false)
    }

    func testEquatablePropertyIdempodent() {
        let a = Property(\WithEquatableProperty.foo, SomeEquatable("foo"))

        XCTAssertEqual(a == a, true)
    }

    func testEquatablePropertyEqual() {
        let a = Property(\WithEquatableProperty.foo, SomeEquatable("foo"))
        let b = Property(\WithEquatableProperty.foo, SomeEquatable("foo"))

        XCTAssertEqual(a == b, true)
    }

    func testEquatablePropertyValuesDifferent() {
        let a = Property(\WithEquatableProperty.foo, SomeEquatable("foo"))
        let b = Property(\WithEquatableProperty.foo, SomeEquatable("bar"))

        XCTAssertEqual(a == b, false)
    }

    func testEquatablePropertyTypesDifferent() {
        let a = Property(\WithEquatableProperty.foo, SomeEquatable("foo"))
        let b = Property(\WithEquatableProperty.foo, SomeEquatable(123))

        XCTAssertEqual(a == b, false)
    }

    func testFunctionPropertyIdempodent() {
        let a = Property(\WithFunctionProperty.foo, { $0 })

        XCTAssertEqual(a == a, true)
    }

    func testFunctionPropertyEqual() {
        let function: (Bool) -> Bool = { $0 }
        let a = Property(\WithFunctionProperty.foo, function)
        let b = Property(\WithFunctionProperty.foo, function)

        XCTAssertEqual(a == b, true)
    }

    func testFunctionPropertyDifferent() {
        let a = Property(\WithFunctionProperty.foo, { $0 })
        let b = Property(\WithFunctionProperty.foo, { $0 })

        XCTAssertEqual(a == b, false)
    }

    func testFunctionPropertyUnrelated() {
        let a = Property(\WithFunctionProperty.foo, { $0 })
        let b = Property(\WithFunctionProperty.bar, false)

        XCTAssertEqual(a == b, false)
    }

    func testPropertyIdempodent() {
        let a = Property(\WithProperty.foo, "foo")

        XCTAssertEqual(a == a, true)
    }

    func testPropertyNeverEqual() {
        let a = Property(\WithProperty.foo, "foo")
        let b = Property(\WithProperty.foo, "foo")

        XCTAssertEqual(a == b, false)
    }

    func testApply() {
        let withHashableProperty = WithHashableProperty("foo")
        let value = SomeHashable("bar")
        let property = Property(\WithHashableProperty.foo, value)

        property.apply(withHashableProperty)

        XCTAssertEqual(withHashableProperty.foo, SomeHashable("bar"))
    }
}
