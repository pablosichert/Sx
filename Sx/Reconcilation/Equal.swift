public struct Equal<T: Equatable> {
    public static func call(_ a: Any, _ b: Any) -> Bool {
        guard let a = a as? T, let b = b as? T else {
            return false
        }

        return a == b
    }
}
