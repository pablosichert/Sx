import struct Sx.Property

infix operator =>: AssignmentPrecedence

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

public func => <Root, Arguments, Return>(
    path: ReferenceWritableKeyPath<Root, (Arguments) -> Return>,
    value: @escaping (Arguments) -> Return
) -> Property<Root> {
    return Property(path, value)
}

public func => <Root, Value>(
    path: ReferenceWritableKeyPath<Root, Value>,
    value: Value
) -> Property<Root> {
    return Property(path, value)
}
