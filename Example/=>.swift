import struct Sx.Property

infix operator =>

public func => <Root, Value>(
    path: ReferenceWritableKeyPath<Root, Value>,
    value: Value
) -> Property<Root> where Value: Hashable {
    return Property(path, value)
}

public func => <Root, Value>(
    path: ReferenceWritableKeyPath<Root, Value>,
    value: Value
) -> Property<Root> where Value: Equatable {
    return Property(path, value)
}

public func => <Root, Value>(
    path: ReferenceWritableKeyPath<Root, Value>,
    value: Value
) -> Property<Root> {
    return Property(path, value)
}
