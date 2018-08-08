public extension ReferenceWritableKeyPath {
    public static func - <Root, Value>(
        lhs: ReferenceWritableKeyPath<Root, Value>,
        rhs: Value
    ) -> Property<Root> {
        return Property<Root>(lhs, rhs)
    }
}
