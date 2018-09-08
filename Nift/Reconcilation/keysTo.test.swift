import enum Reconcilation.Behavior
import func Reconcilation.keysTo
import protocol Reconcilation.Node
import protocol Reconcilation.NodeInstance
import struct Reconcilation.Operations
import func XCTest.XCTAssert
import class XCTest.XCTestCase

private struct FakeProperties {}

private struct FakeNode: Node {
    var children: [Node]
    var ComponentType: Any.Type
    var equal: (Any, Any) -> Bool
    var key: String?
    var properties: Any
    var type: Behavior

    init(key: String? = nil) {
        self.children = []
        self.ComponentType = Any.self
        self.equal = { _, _ in true }
        self.key = key
        self.properties = FakeProperties()
        self.type = .Native
    }
}

private class FakeInstance: NodeInstance {
    var node: Node
    var index: Int
    var instances: [NodeInstance]
    var parent: NodeInstance?

    init(node: Node) {
        self.node = node
        self.index = 0
        self.instances = []
    }

    func mount() -> [Any] {
        return []
    }

    func update(node _: Node) {}

    func update(operations _: Operations) {}
}

// swiftlint:disable:next type_name
class keysToTest: XCTestCase {
    func testInstancesWithoutKeys() {
        let foo = FakeInstance(node: FakeNode())
        let bar = FakeInstance(node: FakeNode())

        let (map, rest) = keysTo(instances: [foo, bar])

        XCTAssert(map.isEmpty)
        XCTAssert(rest.count == 2)
        XCTAssert(rest[0] === foo)
        XCTAssert(rest[1] === bar)
    }

    func testInstancesWithKeys() {
        let foo = FakeInstance(node: FakeNode(key: "foo"))
        let bar = FakeInstance(node: FakeNode(key: "bar"))

        let (map, rest) = keysTo(instances: [foo, bar])

        XCTAssert(map.count == 2)
        XCTAssert(map["foo"] === foo)
        XCTAssert(map["bar"] === bar)
        XCTAssert(rest.isEmpty)
    }

    func testInstancesWithSomeKeys() {
        let foo = FakeInstance(node: FakeNode(key: "foo"))
        let bar = FakeInstance(node: FakeNode())
        let baz = FakeInstance(node: FakeNode(key: "baz"))
        let bat = FakeInstance(node: FakeNode())

        let (map, rest) = keysTo(instances: [foo, bar, baz, bat])

        XCTAssert(map.count == 2)
        XCTAssert(map["foo"] === foo)
        XCTAssert(map["baz"] === baz)
        XCTAssert(rest.count == 2)
        XCTAssert(rest[0] === bar)
        XCTAssert(rest[1] === bat)
    }
}
