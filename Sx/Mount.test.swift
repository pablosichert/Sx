import protocol Reconcilation.NodeInstance
import struct Sx.Mount
import protocol Sx.Node
import struct Sx.Operations
import func XCTest.XCTAssertEqual
import class XCTest.XCTestCase

private struct FakeNode: Node {
    var children: [Node] = []
    var ComponentType: Any.Type = Any.self
    var equal: (Any, Any) -> Bool = { _, _ in false }
    var InstanceType: NodeInstance.Type = FakeInstance.self
    var key: String?
    var properties: Any

    init(properties: Any) {
        self.properties = properties
    }
}

private class FakeInstance: NodeInstance {
    var node: Node
    var index: Int = -1
    var instances: [NodeInstance] = []
    var parent: NodeInstance?

    required init(node: Node, parent _: NodeInstance?, index _: Int) {
        self.node = node
    }

    func mount() -> [Any] {
        return [node.properties]
    }

    func update(node _: Node) {}

    func update(operations _: Operations) {}
}

class MountTest: XCTestCase {
    func testMountNode() {
        let mounts = Mount<Int>(FakeNode(properties: 123))

        XCTAssertEqual(mounts.elements.count, 1)
        XCTAssertEqual(mounts.elements as! [Int], [123])
        XCTAssertEqual(mounts[0], 123)
    }

    func testMountNodes() {
        let mounts = Mount<Int>([
            FakeNode(properties: 123),
            FakeNode(properties: 456),
        ])

        XCTAssertEqual(mounts.elements.count, 2)
        XCTAssertEqual(mounts.elements as! [Int], [123, 456])
        XCTAssertEqual(mounts[0], 123)
        XCTAssertEqual(mounts[1], 456)
    }
}
