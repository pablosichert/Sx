import struct Reconcilation.Operations
import func XCTest.XCTAssert
import class XCTest.XCTestCase

class OperationsTest: XCTestCase {
    func testInsert() {
        var operations = Operations()
        let insert: (mount: Any, index: Int) = (mount: 0, index: 0)

        XCTAssert(operations.inserts.count == 0)

        operations.insert(insert)

        XCTAssert(!operations.isEmpty)
        XCTAssert(operations.inserts.count == 1)
        XCTAssert(operations.inserts[0].mount as! Int == 0)
        XCTAssert(operations.inserts[0].index == 0)
    }

    func testRemove() {
        var operations = Operations()
        let remove: (mount: Any, index: Int) = (mount: 0, index: 0)

        XCTAssert(operations.removes.count == 0)

        operations.remove(remove)

        XCTAssert(!operations.isEmpty)
        XCTAssert(operations.removes.count == 1)
        XCTAssert(operations.removes[0].mount as! Int == 0)
        XCTAssert(operations.removes[0].index == 0)
    }

    func testReorder() {
        var operations = Operations()
        let reorder: (mount: Any, from: Int, to: Int) = (mount: 0, from: 0, to: 0)

        XCTAssert(operations.reorders.count == 0)

        operations.reorder(reorder)

        XCTAssert(!operations.isEmpty)
        XCTAssert(operations.reorders.count == 1)
        XCTAssert(operations.reorders[0].mount as! Int == 0)
        XCTAssert(operations.reorders[0].from == 0)
        XCTAssert(operations.reorders[0].to == 0)
    }

    func testReplace() {
        var operations = Operations()
        let replace: (old: Any, new: Any, index: Int) = (old: 0, new: 0, index: 0)

        XCTAssert(operations.replaces.count == 0)

        operations.replace(replace)

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
