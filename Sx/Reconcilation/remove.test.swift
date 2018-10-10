import protocol Reconcilation.Node
import protocol Reconcilation.NodeInstance
import struct Reconcilation.Operations
import func Reconcilation.remove
import func XCTest.XCTAssertEqual
import class XCTest.XCTestCase

private struct FakeNode: Node {
    var children: [Node] = []
    var ComponentType: Any.Type = Any.self
    var equal: (Any, Any) -> Bool = { _, _ in true }
    var InstanceType: NodeInstance.Type = FakeInstance.self
    var key: String?
    var properties: Any = 0
}

private class FakeInstance: NodeInstance {
    var node: Node = FakeNode()
    var index: Int
    var instances: [NodeInstance] = []
    var parent: NodeInstance?
    let mounts: Int

    required init(node: Node, parent _: NodeInstance? = nil, index: Int = 0) {
        self.index = index
        self.node = node
        self.mounts = 0
    }

    init(mounts: Int, index: Int = 0) {
        self.index = index
        self.mounts = mounts
    }

    func mount() -> [Any] {
        return (0 ..< mounts).map({ String($0) })
    }

    func update(node _: Node) {}

    func update(operations _: Operations) {}
}

// swiftlint:disable:next type_name
class removeTest: XCTestCase {
    func testRemoveAtIndex() {
        let instance = FakeInstance(mounts: 3, index: 5)
        var operations = Operations()

        remove(
            instance: instance,
            remove: { operations.add(remove: $0) }
        )

        XCTAssertEqual(operations.removes.count, 3)
        XCTAssertEqual(operations.removes[0].index, 5)
        XCTAssertEqual(operations.removes[0].mount as! String, "0")
        XCTAssertEqual(operations.removes[1].index, 6)
        XCTAssertEqual(operations.removes[1].mount as! String, "1")
        XCTAssertEqual(operations.removes[2].index, 7)
        XCTAssertEqual(operations.removes[2].mount as! String, "2")
    }
}
