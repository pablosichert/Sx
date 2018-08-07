import struct Foundation.UUID

private func applier<Root, Value>(path: ReferenceWritableKeyPath<Root, Value>, value: Value) -> (Root) -> Void {
    return { (_ root: Root) -> Void in
        root[keyPath: path] = value
    }
}

public struct Property<Root>: Equatable {
    public static func == (lhs: Property<Root>, rhs: Property<Root>) -> Bool {
        return (
            lhs.pathsEqual(lhs.path, rhs.path) &&
                (lhs.valuesEqual(lhs.value, rhs.value) || lhs.id == rhs.id)
        )
    }

    public let apply: (Root) -> Void
    public let id = UUID()
    public let path: Any
    public let pathsEqual: (Any, Any) -> Bool
    public let value: Any
    public let valuesEqual: (Any, Any) -> Bool

    public init<Value>(
        _ path: ReferenceWritableKeyPath<Root, Value>,
        _ value: Value
    ) where Value: Equatable {
        typealias Path = ReferenceWritableKeyPath<Root, Value>

        self.apply = applier(path: path, value: value)
        self.path = path
        self.pathsEqual = Equal<Path>.call
        self.value = value
        self.valuesEqual = Equal<Value>.call
    }

    public init<Value>(
        _ path: ReferenceWritableKeyPath<Root, Value>,
        _ value: Value
    ) {
        typealias Path = ReferenceWritableKeyPath<Root, Value>

        self.apply = applier(path: path, value: value)
        self.path = path
        self.pathsEqual = Equal<Path>.call
        self.value = value
        self.valuesEqual = { (_: Any, _: Any) -> Bool in false }
    }
}
