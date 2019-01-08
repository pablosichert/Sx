import struct Foundation.UUID

private struct Static {
    /* Use this value as a fallback, when no sensible hash can be computed.
     * This is the case when the property does not conform to the hashable protocol. */
    static let hashValue = 0
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
    public let id: UUID
    public let path: Any
    public let pathsEqual: (Any, Any) -> Bool
    public let value: Any
    public let valuesEqual: (Any, Any) -> Bool

    init<Value>(
        hashValue: Int,
        id: UUID = UUID(),
        path: ReferenceWritableKeyPath<Root, Value>,
        value: Value,
        valuesEqual: @escaping (Any, Any) -> Bool
    ) {
        typealias Path = ReferenceWritableKeyPath<Root, Value>

        self.apply = { root in root[keyPath: path] = value }
        self.hashValue = hashValue
        self.id = id
        self.path = path
        self.pathsEqual = Equal<Path>.call
        self.value = value
        self.valuesEqual = valuesEqual
    }

    public init<Value>(
        _ path: ReferenceWritableKeyPath<Root, Value>,
        _ value: Value
    ) where Value: Hashable {
        self.init(
            hashValue: value.hashValue,
            path: path,
            value: value,
            valuesEqual: Equal<Value>.call
        )
    }

    public init<Value>(
        _ path: ReferenceWritableKeyPath<Root, Value>,
        _ value: Value
    ) where Value: Equatable {
        self.init(
            hashValue: Static.hashValue,
            path: path,
            value: value,
            valuesEqual: Equal<Value>.call
        )
    }

    public init<Value>(
        _ path: ReferenceWritableKeyPath<Root, Value>,
        _ value: Value
    ) {
        let id = UUID()

        self.init(
            hashValue: id.hashValue,
            id: id,
            path: path,
            value: value,
            valuesEqual: { _, _ in false }
        )
    }
}
