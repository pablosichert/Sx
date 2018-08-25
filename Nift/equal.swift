/*
 Based on the reverse engineering efforts of Dmitry Rodionov
 https://github.com/rodionovd/SWRoute/wiki/Function-hooking-in-Swift
 */
private struct FunctionWrapper {
    let unknown0: UnsafePointer<Any>
    let function: UnsafePointer<Function>
}

private struct Function: Equatable {
    let type: UnsafePointer<Any>
    let unknown0: UnsafePointer<Any>
    let address: UnsafePointer<Any>
    let context: UnsafePointer<Any>

    static func from<Arguments, Return>(
        _ function: (Arguments) -> Return
    ) -> Function {
        return unsafeBitCast(function, to: FunctionWrapper.self).function.pointee
    }
}

public func equal<Arguments, Return>(
    _ lhs: (Arguments) -> Return,
    _ rhs: (Arguments) -> Return
) -> Bool {
    let lhs = Function.from(lhs)
    let rhs = Function.from(rhs)

    return lhs.address == rhs.address
}
