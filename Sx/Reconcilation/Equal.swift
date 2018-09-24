public struct Equal<T: Equatable> {
    public static func call(a: Any, b: Any) -> Bool {
        if let a = a as? T, let b = b as? T {
            return a == b
        }

        return false
    }
}
