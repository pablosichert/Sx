import func Reconcilation.instantiate
import protocol Reconcilation.Native
import protocol Reconcilation.Node
import struct Reconcilation.Operations
import func Reconcilation.reconcile
import func XCTest.XCTAssert
import class XCTest.XCTestCase

private func NativeA(
    key: String? = nil,
    children: [Node] = []
) -> Node {
    return Native.Node(
        key: key,
        properties: ComponentA.Properties(),
        Type: ComponentA.self,
        children
    )
}

private struct ComponentA: Native.Renderable {
    struct Properties: Equatable {}

    init(properties _: Any, children _: [Any]) {}

    func insert(mount _: Any, index _: Int) {}

    func update(properties _: Any) {}

    func update(operations _: Operations) {}

    func update(properties _: Any, operations _: Operations) {}

    func remove(mount _: Any, index _: Int) {}

    func render() -> Any {
        return {}
    }

    func reorder(mount _: Any, from _: Int, to _: Int) {}

    func replace(old _: Any, new _: Any, index _: Int) {}
}

private func NativeB(
    key: String? = nil,
    children: [Node] = []
) -> Node {
    return Native.Node(
        key: key,
        properties: ComponentB.Properties(),
        Type: ComponentB.self,
        children
    )
}

private struct ComponentB: Native.Renderable {
    struct Properties: Equatable {}

    init(properties _: Any, children _: [Any]) {}

    func insert(mount _: Any, index _: Int) {}

    func update(properties _: Any) {}

    func update(operations _: Operations) {}

    func update(properties _: Any, operations _: Operations) {}

    func remove(mount _: Any, index _: Int) {}

    func render() -> Any {
        return {}
    }

    func reorder(mount _: Any, from _: Int, to _: Int) {}

    func replace(old _: Any, new _: Any, index _: Int) {}
}

// swiftlint:disable:next type_name
class reconcileTest: XCTestCase {
    func testInsertWithoutKeys() {
        let old = [Node]()
        let new = [NativeA()]
        let parent = NativeA(children: old)
        let instance = instantiate(node: parent, index: 0)

        let reconcilation = reconcile(
            instances: instance.instances,
            instantiate: instantiate,
            nodes: new,
            parent: instance
        )

        XCTAssert(reconcilation.instances.count == 1)
        XCTAssert(reconcilation.operations.inserts.count == 1)
        XCTAssert(reconcilation.operations.removes.isEmpty)
        XCTAssert(reconcilation.operations.reorders.isEmpty)
        XCTAssert(reconcilation.operations.replaces.isEmpty)
    }

    func testRemoveWithoutKeys() {
        let old = [NativeA()]
        let new = [Node]()
        let parent = NativeA(children: old)
        let instance = instantiate(node: parent, index: 0)

        let reconcilation = reconcile(
            instances: instance.instances,
            instantiate: instantiate,
            nodes: new,
            parent: instance
        )

        XCTAssert(reconcilation.instances.isEmpty)
        XCTAssert(reconcilation.operations.removes.count == 1)
        XCTAssert(reconcilation.operations.inserts.isEmpty)
        XCTAssert(reconcilation.operations.reorders.isEmpty)
        XCTAssert(reconcilation.operations.replaces.isEmpty)
    }

    func testReplaceWithoutKeys() {
        let old = [NativeA()]
        let new = [NativeB()]
        let parent = NativeA(children: old)
        let instance = instantiate(node: parent, index: 0)

        let reconcilation = reconcile(
            instances: instance.instances,
            instantiate: instantiate,
            nodes: new,
            parent: instance
        )

        XCTAssert(reconcilation.instances.count == 1)
        XCTAssert(reconcilation.operations.replaces.count == 1)
        XCTAssert(reconcilation.operations.inserts.isEmpty)
        XCTAssert(reconcilation.operations.removes.isEmpty)
        XCTAssert(reconcilation.operations.reorders.isEmpty)
    }

    func testUpdateWithoutKeys() {
        let old = [NativeA()]
        let new = [NativeA()]
        let parent = NativeA(children: old)
        let instance = instantiate(node: parent, index: 0)

        let reconcilation = reconcile(
            instances: instance.instances,
            instantiate: instantiate,
            nodes: new,
            parent: instance
        )

        XCTAssert(reconcilation.instances.count == 1)
        XCTAssert(reconcilation.operations.isEmpty)
    }
}
