import protocol Reconcilation.Native
import class Reconcilation.NativeInstance
import protocol Reconcilation.Node
import protocol Reconcilation.NodeInstance
import struct Reconcilation.Operations
import func XCTest.XCTAssertEqual
import class XCTest.XCTestCase

private struct FakeComponent: Native.Renderable {
    init(properties _: Any, children _: [Any]) {}

    func insert(mount _: Any, index _: Int) {}

    func update(properties _: (next: Any, previous: Any)) {}

    func update(operations _: Operations) {}

    func update(properties _: (next: Any, previous: Any), operations _: Operations) {}

    func remove(mount _: Any, index _: Int) {}

    func render() -> [Any] {
        return []
    }

    func reorder(mount _: Any, from _: Int, to _: Int) {}

    func replace(old _: Any, new _: Any, index _: Int) {}
}

private struct FakeNode: Node {
    var children: [Node] = []
    var ComponentType: Any.Type = FakeComponent.self
    var equal: (Any, Any) -> Bool = { _, _ in false }
    var InstanceType: NodeInstance.Type = NativeInstance.self
    var key: String?
    var properties: Any = 0
}

class NativeInstanceTest: XCTestCase {
    func testInit() {
        let node = FakeNode()
        let instance = NativeInstance(node: node, index: 0)

        XCTAssertEqual(instance.index, 0)
    }
}
