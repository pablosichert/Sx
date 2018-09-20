import func Reconcilation.instantiate
import protocol Reconcilation.Native
import protocol Reconcilation.Node
import struct Reconcilation.Operations
import func Reconcilation.reconcile
import func XCTest.XCTAssert
import class XCTest.XCTestCase

private func NativeA(
    items: Int = 1,
    key: String? = nil,
    children: [Node] = []
) -> Node {
    return Native.Node(
        key: key,
        properties: ComponentA.Properties(items: items),
        Type: ComponentA.self,
        children
    )
}

private struct ComponentA: Native.Renderable {
    struct Properties: Equatable {
        let items: Int
    }

    let properties: Properties

    init(properties: Any, children _: [Any]) {
        self.properties = properties as! Properties
    }

    func insert(mount _: Any, index _: Int) {}

    func update(properties _: Any) {}

    func update(operations _: Operations) {}

    func update(properties _: Any, operations _: Operations) {}

    func remove(mount _: Any, index _: Int) {}

    func render() -> [Any] {
        return [Any].init(repeating: 0, count: self.properties.items)
    }

    func reorder(mount _: Any, from _: Int, to _: Int) {}

    func replace(old _: Any, new _: Any, index _: Int) {}
}

private func NativeB(
    items: Int = 1,
    key: String? = nil,
    children: [Node] = []
) -> Node {
    return Native.Node(
        key: key,
        properties: ComponentB.Properties(items: items),
        Type: ComponentB.self,
        children
    )
}

private struct ComponentB: Native.Renderable {
    struct Properties: Equatable {
        let items: Int
    }

    let properties: Properties

    init(properties: Any, children _: [Any]) {
        self.properties = properties as! Properties
    }

    func insert(mount _: Any, index _: Int) {}

    func update(properties _: Any) {}

    func update(operations _: Operations) {}

    func update(properties _: Any, operations _: Operations) {}

    func remove(mount _: Any, index _: Int) {}

    func render() -> [Any] {
        return [Any].init(repeating: 0, count: self.properties.items)
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

    func testInsertWithKeys() {
        let old = [Node]()
        let new = [NativeA(key: "x")]
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

    func testRemoveWithKeys() {
        let old = [NativeA(key: "x")]
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

    func testReplaceInsertWithoutKeys() {
        let old = [NativeA()]
        let new = [NativeB(items: 2)]
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
        XCTAssert(reconcilation.operations.inserts.count == 1)
        XCTAssert(reconcilation.operations.removes.isEmpty)
        XCTAssert(reconcilation.operations.reorders.isEmpty)
    }

    func testReplaceRemoveWithoutKeys() {
        let old = [NativeA(items: 2)]
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
        XCTAssert(reconcilation.operations.removes.count == 1)
        XCTAssert(reconcilation.operations.inserts.isEmpty)
        XCTAssert(reconcilation.operations.reorders.isEmpty)
    }

    func testReplaceWithKeys() {
        let old = [NativeA(key: "x")]
        let new = [NativeB(key: "x")]
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

    func testUpdateWithKeys() {
        let old = [NativeA(key: "x")]
        let new = [NativeA(key: "x")]
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

    func testReorderWithKeys() {
        let old = [NativeA(key: "1"), NativeA(key: "2")]
        let new = [NativeA(key: "2"), NativeA(key: "1")]
        let parent = NativeA(children: old)
        let instance = instantiate(node: parent, index: 0)

        let reconcilation = reconcile(
            instances: instance.instances,
            instantiate: instantiate,
            nodes: new,
            parent: instance
        )

        XCTAssert(reconcilation.instances.count == 2)
        XCTAssert(reconcilation.operations.reorders.count == 2)
        XCTAssert(reconcilation.operations.replaces.isEmpty)
        XCTAssert(reconcilation.operations.inserts.isEmpty)
        XCTAssert(reconcilation.operations.removes.isEmpty)
    }
}
