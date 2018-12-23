import protocol Sx.Node

infix operator &&

public func && (lhs: Bool, rhs: () -> Node) -> Node? {
    guard lhs else {
        return nil
    }

    return rhs()
}

public func && (lhs: Bool, rhs: () -> [Node]) -> [Node] {
    guard lhs else {
        return []
    }

    return rhs()
}
