public class Equal<T: Equatable> {
    public static func call(a: Any, b: Any) -> Bool { // swiftlint:disable:this identifier_name
        return a as! T == b as! T
    }
}
