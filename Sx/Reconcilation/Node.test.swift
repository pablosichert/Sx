import Reconcilation
import func XCTest.XCTAssertEqual
import class XCTest.XCTestCase

struct NodeImplementation: Node {
    let children: [Node]
    let ComponentType: Any.Type
    let equal: (Any, Any) -> Bool
    let InstanceType: NodeInstance.Type
    let key: String?
    let properties: Any
}

class NodeTest: XCTestCase {
    func testNodesEqual() {
        let equal = { (a: Any, b: Any) -> Bool in
            guard let a = a as? Int, let b = b as? Int else {
                return false
            }

            return a == b
        }

        let a = NodeImplementation(
            children: [],
            ComponentType: Any.self,
            equal: equal,
            InstanceType: NativeInstance.self,
            key: nil,
            properties: 0
        )

        let b = NodeImplementation(
            children: [],
            ComponentType: Any.self,
            equal: equal,
            InstanceType: NativeInstance.self,
            key: nil,
            properties: 0
        )

        XCTAssertEqual(a == b, true)
        XCTAssertEqual(a != b, false)
    }

    func testNodeArrayEqual() {
        let equal = { (a: Any, b: Any) -> Bool in
            guard let a = a as? Int, let b = b as? Int else {
                return false
            }

            return a == b
        }

        let a = [
            NodeImplementation(
                children: [],
                ComponentType: Any.self,
                equal: equal,
                InstanceType: NativeInstance.self,
                key: nil,
                properties: 0
            ),
        ]

        let b = [
            NodeImplementation(
                children: [],
                ComponentType: Any.self,
                equal: equal,
                InstanceType: NativeInstance.self,
                key: nil,
                properties: 0
            ),
        ]

        XCTAssertEqual(a == b, true)
        XCTAssertEqual(a != b, false)
    }
}
