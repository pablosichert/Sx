import struct Reconcilation.StaticQueue
import func XCTest.XCTAssertEqual
import class XCTest.XCTestCase

class StaticQueueTest: XCTestCase {
    func testDequeue() {
        let array: [Int] = [1, 2, 3]
        var queue = StaticQueue(array)

        XCTAssertEqual(queue.dequeue(), 1)
        XCTAssertEqual(queue.dequeue(), 2)
        XCTAssertEqual(queue.dequeue(), 3)
    }

    func testDequeueEmpty() {
        let array: [Int] = []
        var queue = StaticQueue(array)

        XCTAssertEqual(queue.dequeue(), nil)
    }

    func testSequence() {
        let array: [Int] = [1, 2, 3]
        let queue = StaticQueue(array)

        var result: [Int] = []

        for i in queue {
            result.append(i)
        }

        XCTAssertEqual(array, result)
    }
}
