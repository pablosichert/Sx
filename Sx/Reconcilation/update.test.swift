import protocol Reconcilation.Node
import protocol Reconcilation.NodeInstance
import struct Reconcilation.Operations
import func Reconcilation.update
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
    var instances: [NodeInstance]
    var parent: NodeInstance?
    let update_: (Node) -> Void
    let name: String

    required init(node _: Node, parent _: NodeInstance? = nil, index: Int) {
        self.instances = []
        self.index = index
        self.update_ = { _ in }
        self.name = ""
    }

    init(children: [NodeInstance] = [], update: @escaping (Node) -> Void, name: String = "", index: Int) {
        self.instances = children
        self.update_ = update
        self.index = index
        self.name = name
    }

    func mount() -> [Any] {
        if instances.count > 0 {
            return instances.map({ ($0 as! FakeInstance).name })
        }

        return [name]
    }

    func update(node _: Node) {
        update_(node)
    }

    func update(operations _: Operations) {}
}

// swiftlint:disable:next type_name
class updateTest: XCTestCase {
    func testIndicesEqual() {
        var updates: [Node] = []

        let foo = FakeInstance(
            update: { updates.append($0) },
            index: 0
        )

        let bar = FakeInstance(
            update: { updates.append($0) },
            index: 1
        )

        let instance = FakeInstance(
            children: [
                foo,
                bar,
            ],
            update: { updates.append($0) },
            index: 0
        )

        var operations = Operations()

        let count = update(
            index: 0,
            instance: instance,
            node: FakeNode(),
            reorder: { operations.add(reorder: $0) }
        )

        XCTAssertEqual(updates.count, 1)
        XCTAssertEqual(count, 2)
        XCTAssertEqual(operations.reorders.count, 0)
        XCTAssertEqual(instance.index, 0)
        XCTAssertEqual(foo.index, 0)
        XCTAssertEqual(bar.index, 1)
    }

    func testIndicesDifferent() {
        var updates: [Node] = []

        let foo = FakeInstance(
            update: { updates.append($0) },
            name: "Bar",
            index: 0
        )

        let bar = FakeInstance(
            update: { updates.append($0) },
            name: "Baz",
            index: 1
        )

        let instance = FakeInstance(
            children: [
                foo,
                bar,
            ],
            update: { updates.append($0) },
            name: "Foo",
            index: 0
        )

        var operations = Operations()

        let count = update(
            index: 5,
            instance: instance,
            node: FakeNode(),
            reorder: { operations.add(reorder: $0) }
        )

        XCTAssertEqual(updates.count, 1)
        XCTAssertEqual(count, 2)
        XCTAssertEqual(operations.reorders.count, 2)
        XCTAssertEqual(operations.reorders[0].mount as! String, "Bar")
        XCTAssertEqual(operations.reorders[0].from, 0)
        XCTAssertEqual(operations.reorders[0].to, 5)
        XCTAssertEqual(operations.reorders[1].mount as! String, "Baz")
        XCTAssertEqual(operations.reorders[1].from, 1)
        XCTAssertEqual(operations.reorders[1].to, 6)
        XCTAssertEqual(instance.index, 5)
        XCTAssertEqual(foo.index, 5)
        XCTAssertEqual(bar.index, 6)
    }
}
