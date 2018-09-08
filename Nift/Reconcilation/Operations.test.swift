import struct Reconcilation.Operations
import func XCTest.XCTAssert
import class XCTest.XCTestCase

class OperationsTest: XCTestCase {
    func testInsert() {
        var operations = Operations()

        XCTAssert(operations.inserts.count == 0)

        operations.add(insert: (mount: 0, index: 0))

        XCTAssert(!operations.isEmpty)
        XCTAssert(operations.inserts.count == 1)
        XCTAssert(operations.inserts[0].mount as! Int == 0)
        XCTAssert(operations.inserts[0].index == 0)
    }

    func testRemove() {
        var operations = Operations()

        XCTAssert(operations.removes.count == 0)

        operations.add(remove: (mount: 0, index: 0))

        XCTAssert(!operations.isEmpty)
        XCTAssert(operations.removes.count == 1)
        XCTAssert(operations.removes[0].mount as! Int == 0)
        XCTAssert(operations.removes[0].index == 0)
    }

    func testReorder() {
        var operations = Operations()

        XCTAssert(operations.reorders.count == 0)

        operations.add(reorder: (mount: 0, from: 0, to: 0))

        XCTAssert(!operations.isEmpty)
        XCTAssert(operations.reorders.count == 1)
        XCTAssert(operations.reorders[0].mount as! Int == 0)
        XCTAssert(operations.reorders[0].from == 0)
        XCTAssert(operations.reorders[0].to == 0)
    }

    func testReplace() {
        var operations = Operations()

        XCTAssert(operations.replaces.count == 0)

        operations.add(replace: (old: 0, new: 0, index: 0))

        XCTAssert(!operations.isEmpty)
        XCTAssert(operations.replaces.count == 1)
        XCTAssert(operations.replaces[0].old as! Int == 0)
        XCTAssert(operations.replaces[0].new as! Int == 0)
        XCTAssert(operations.replaces[0].index == 0)
    }

    func testIsEmpty() {
        let operations = Operations()

        XCTAssert(operations.isEmpty)
    }
}
