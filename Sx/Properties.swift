public struct Properties<Root> {
    let array: [Property<Root>]
    let set: Set<Property<Root>>
    let map: [PartialKeyPath<Root>: Any]

    public init() {
        self.init([])
    }

    public init(_ properties: [Property<Root>]) {
        var map: [PartialKeyPath<Root>: Any] = [:]

        for property in properties {
            map[property.path as! PartialKeyPath<Root>] = property.value
        }

        self.array = properties
        self.set = Set(properties)
        self.map = map
    }

    public func contains(_ property: Property<Root>) -> Bool {
        return set.contains(property)
    }

    public subscript<Value>(index: KeyPath<Root, Value>) -> Value? {
        guard let value = map[index] else {
            return nil
        }

        assert(value is Value, "Type of value does not match generic <Value> of keypath")

        return (value as! Value)
    }
}

extension Properties: Equatable {
    public static func == (lhs: Properties, rhs: Properties) -> Bool {
        return lhs.set == rhs.set
    }
}

extension Properties: Sequence {
    public func makeIterator() -> IndexingIterator<[Property<Root>]> {
        return array.makeIterator()
    }
}
