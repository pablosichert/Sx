import struct Foundation.UUID

private func applier<Root, Value>(
    path: ReferenceWritableKeyPath<Root, Value>,
    value: Value
) -> (Root) -> Void {
    return { (_ root: Root) -> Void in
        root[keyPath: path] = value
    }
}

private struct Static {
    /* Use this value as a fallback, when no sensible hash can be computed.
     * Should be avoided if possible since sets / hash maps will perform badly. */
    static let hashValue = UUID().hashValue
}

public struct Property<Root>: Hashable {
    public static func == (lhs: Property<Root>, rhs: Property<Root>) -> Bool {
        let pathsEqual = lhs.pathsEqual(lhs.path, rhs.path)
        let valuesEqual = lhs.valuesEqual(lhs.value, rhs.value)
        let idsEqual = lhs.id == rhs.id

        return pathsEqual && (valuesEqual || idsEqual)
    }

    public let apply: (Root) -> Void
    public let hashValue: Int
    public let id = UUID()
    public let path: Any
    public let pathsEqual: (Any, Any) -> Bool
    public let value: Any
    public let valuesEqual: (Any, Any) -> Bool

    public init<Value>(
        _ path: ReferenceWritableKeyPath<Root, Value>,
        _ value: Value
    ) where Value: Hashable {
        typealias Path = ReferenceWritableKeyPath<Root, Value>

        self.apply = applier(path: path, value: value)
        self.hashValue = value.hashValue
        self.path = path
        self.pathsEqual = Equal<Path>.call
        self.value = value
        self.valuesEqual = Equal<Value>.call
    }

    public init<Value>(
        _ path: ReferenceWritableKeyPath<Root, Value>,
        _ value: Value
    ) where Value: Equatable {
        typealias Path = ReferenceWritableKeyPath<Root, Value>

        self.apply = applier(path: path, value: value)
        self.hashValue = Static.hashValue
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
        self.hashValue = id.hashValue
        self.path = path
        self.pathsEqual = Equal<Path>.call
        self.value = value
        self.valuesEqual = { (_: Any, _: Any) -> Bool in false }
    }
}
