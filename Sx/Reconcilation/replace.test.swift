import protocol Reconcilation.Node
import protocol Reconcilation.NodeInstance
import struct Reconcilation.Operations
import func Reconcilation.replace
import func XCTest.XCTAssertEqual
import class XCTest.XCTestCase

private struct FakeNode: Node {
    var children: [Node] = []
    var ComponentType: Any.Type = Any.self
    var equal: (Any, Any) -> Bool = { _, _ in false }
    var InstanceType: NodeInstance.Type = FakeInstance.self
    var key: String?
    var properties: Any = 0
}

private class FakeInstance: NodeInstance {
    var node: Node = FakeNode()
    var index: Int
    var instances: [NodeInstance] = []
    var parent: NodeInstance?
    let prefix: String
    let mounts: Int

    required init(node: Node, parent _: NodeInstance? = nil, index: Int = 0) {
        self.index = index
        self.node = node
        self.prefix = ""
        self.mounts = 0
    }

    init(prefix: String, mounts: Int, index: Int = 0) {
        self.index = index
        self.prefix = prefix
        self.mounts = mounts
    }

    func mount() -> [Any] {
        return (0 ..< mounts).map({ "\(prefix)\($0)" })
    }

    func update(node _: Node) {}

    func update(operations _: Operations) {}
}

// swiftlint:disable:next type_name
class replaceTest: XCTestCase {
    func testMountsSameBounds() {
        let a = FakeInstance(prefix: "old", mounts: 3)
        let b = FakeInstance(prefix: "new", mounts: 3)

        var operations = Operations()

        let count = replace(
            new: b,
            old: a,
            insert: { operations.add(insert: $0) },
            remove: { operations.add(remove: $0) },
            replace: { operations.add(replace: $0) }
        )

        XCTAssertEqual(count, 3)
        XCTAssertEqual(operations.inserts.count, 0)
        XCTAssertEqual(operations.removes.count, 0)
        XCTAssertEqual(operations.replaces.count, 3)
        XCTAssertEqual(operations.replaces[0].index, 0)
        XCTAssertEqual(operations.replaces[0].old as! String, "old0")
        XCTAssertEqual(operations.replaces[0].new as! String, "new0")
        XCTAssertEqual(operations.replaces[1].index, 1)
        XCTAssertEqual(operations.replaces[1].old as! String, "old1")
        XCTAssertEqual(operations.replaces[1].new as! String, "new1")
        XCTAssertEqual(operations.replaces[2].index, 2)
        XCTAssertEqual(operations.replaces[2].old as! String, "old2")
        XCTAssertEqual(operations.replaces[2].new as! String, "new2")
    }

    func testMountsBOverlappingA() {
        let a = FakeInstance(prefix: "old", mounts: 3)
        let b = FakeInstance(prefix: "new", mounts: 3, index: 2)

        var operations = Operations()

        let count = replace(
            new: b,
            old: a,
            insert: { operations.add(insert: $0) },
            remove: { operations.add(remove: $0) },
            replace: { operations.add(replace: $0) }
        )

        XCTAssertEqual(count, 3)
        XCTAssertEqual(operations.inserts.count, 2)
        XCTAssertEqual(operations.inserts[0].index, 3)
        XCTAssertEqual(operations.inserts[0].mount as! String, "new1")
        XCTAssertEqual(operations.inserts[1].index, 4)
        XCTAssertEqual(operations.inserts[1].mount as! String, "new2")
        XCTAssertEqual(operations.removes.count, 2)
        XCTAssertEqual(operations.removes[0].index, 0)
        XCTAssertEqual(operations.removes[0].mount as! String, "old0")
        XCTAssertEqual(operations.removes[1].index, 1)
        XCTAssertEqual(operations.removes[1].mount as! String, "old1")
        XCTAssertEqual(operations.replaces.count, 1)
        XCTAssertEqual(operations.replaces[0].index, 2)
        XCTAssertEqual(operations.replaces[0].old as! String, "old2")
        XCTAssertEqual(operations.replaces[0].new as! String, "new0")
    }

    func testMountsAOverlappingB() {
        let a = FakeInstance(prefix: "old", mounts: 3, index: 2)
        let b = FakeInstance(prefix: "new", mounts: 3)

        var operations = Operations()

        let count = replace(
            new: b,
            old: a,
            insert: { operations.add(insert: $0) },
            remove: { operations.add(remove: $0) },
            replace: { operations.add(replace: $0) }
        )

        XCTAssertEqual(count, 3)
        XCTAssertEqual(operations.inserts.count, 2)
        XCTAssertEqual(operations.inserts[0].index, 0)
        XCTAssertEqual(operations.inserts[0].mount as! String, "new0")
        XCTAssertEqual(operations.inserts[1].index, 1)
        XCTAssertEqual(operations.inserts[1].mount as! String, "new1")
        XCTAssertEqual(operations.removes.count, 2)
        XCTAssertEqual(operations.removes[0].index, 3)
        XCTAssertEqual(operations.removes[0].mount as! String, "old1")
        XCTAssertEqual(operations.removes[1].index, 4)
        XCTAssertEqual(operations.removes[1].mount as! String, "old2")
        XCTAssertEqual(operations.replaces.count, 1)
        XCTAssertEqual(operations.replaces[0].index, 2)
        XCTAssertEqual(operations.replaces[0].old as! String, "old0")
        XCTAssertEqual(operations.replaces[0].new as! String, "new2")
    }

    func testMountsBBeforeA() {
        let a = FakeInstance(prefix: "old", mounts: 3)
        let b = FakeInstance(prefix: "new", mounts: 3, index: 5)

        var operations = Operations()

        let count = replace(
            new: b,
            old: a,
            insert: { operations.add(insert: $0) },
            remove: { operations.add(remove: $0) },
            replace: { operations.add(replace: $0) }
        )

        XCTAssertEqual(count, 3)
        XCTAssertEqual(operations.inserts.count, 3)
        XCTAssertEqual(operations.inserts[0].index, 5)
        XCTAssertEqual(operations.inserts[0].mount as! String, "new0")
        XCTAssertEqual(operations.inserts[1].index, 6)
        XCTAssertEqual(operations.inserts[1].mount as! String, "new1")
        XCTAssertEqual(operations.inserts[2].index, 7)
        XCTAssertEqual(operations.inserts[2].mount as! String, "new2")
        XCTAssertEqual(operations.removes.count, 3)
        XCTAssertEqual(operations.removes[0].index, 0)
        XCTAssertEqual(operations.removes[0].mount as! String, "old0")
        XCTAssertEqual(operations.removes[1].index, 1)
        XCTAssertEqual(operations.removes[1].mount as! String, "old1")
        XCTAssertEqual(operations.removes[2].index, 2)
        XCTAssertEqual(operations.removes[2].mount as! String, "old2")
        XCTAssertEqual(operations.replaces.count, 0)
    }

    func testMountsABeforeB() {
        let a = FakeInstance(prefix: "old", mounts: 3, index: 5)
        let b = FakeInstance(prefix: "new", mounts: 3)

        var operations = Operations()

        let count = replace(
            new: b,
            old: a,
            insert: { operations.add(insert: $0) },
            remove: { operations.add(remove: $0) },
            replace: { operations.add(replace: $0) }
        )

        XCTAssertEqual(count, 3)
        XCTAssertEqual(operations.inserts.count, 3)
        XCTAssertEqual(operations.inserts[0].index, 0)
        XCTAssertEqual(operations.inserts[0].mount as! String, "new0")
        XCTAssertEqual(operations.inserts[1].index, 1)
        XCTAssertEqual(operations.inserts[1].mount as! String, "new1")
        XCTAssertEqual(operations.inserts[2].index, 2)
        XCTAssertEqual(operations.inserts[2].mount as! String, "new2")
        XCTAssertEqual(operations.removes.count, 3)
        XCTAssertEqual(operations.removes[0].index, 5)
        XCTAssertEqual(operations.removes[0].mount as! String, "old0")
        XCTAssertEqual(operations.removes[1].index, 6)
        XCTAssertEqual(operations.removes[1].mount as! String, "old1")
        XCTAssertEqual(operations.removes[2].index, 7)
        XCTAssertEqual(operations.removes[2].mount as! String, "old2")
        XCTAssertEqual(operations.replaces.count, 0)
    }
}
