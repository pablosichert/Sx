struct StaticQueue<T>: Sequence, IteratorProtocol {
    let elements: [T]
    var index = 0

    init(_ elements: [T]) {
        self.elements = elements
    }

    mutating func dequeue() -> T? {
        if index >= elements.count {
            return nil
        }

        defer {
            index += 1
        }

        return elements[index]
    }

    mutating func next() -> T? {
        return dequeue()
    }
}
