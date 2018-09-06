public struct StaticQueue<T>: Sequence, IteratorProtocol {
    let elements: [T]
    var index = 0

    public init(_ elements: [T]) {
        self.elements = elements
    }

    public mutating func dequeue() -> T? {
        if index >= elements.count {
            return nil
        }

        defer {
            index += 1
        }

        return elements[index]
    }

    public mutating func next() -> T? {
        return dequeue()
    }
}
