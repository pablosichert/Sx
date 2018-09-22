/*
 Based on ideas in the article about hooking into functions written by Dmitry Rodionov:
 https://github.com/rodionovd/SWRoute/wiki/Function-hooking-in-Swift
 */

private struct FunctionWrapper {
    let unknown0: UnsafePointer<Any>
    let function: UnsafePointer<Function>
}

private struct ContextWrapper {
    let unknown0: UnsafePointer<Any>
    let unknown1: UnsafePointer<Any>
    let context: UnsafePointer<Context>
    let unknown2: UnsafePointer<Any>
}

private struct Context {
    let unkown0: UnsafePointer<Any>
    let unkown1: UnsafePointer<Any>
    let instance: UnsafePointer<Any>
    let unkown2: UnsafePointer<Any>
}

private struct Function: Equatable {
    let unknown0: UnsafePointer<Any>
    let unknown1: UnsafePointer<Any>
    let address: UnsafePointer<Any>
    let contextWrapper: UnsafePointer<ContextWrapper>?

    static func from<Arguments, Return>(
        _ function: @escaping (Arguments) -> Return
    ) -> Function {
        return unsafeBitCast(function, to: FunctionWrapper.self).function.pointee
    }
}

public func compare<Arguments, Return>(
    _ lhs: @escaping (Arguments) -> Return,
    _ rhs: @escaping (Arguments) -> Return
) -> Bool {
    let functionLhs = Function.from(lhs)
    let functionRhs = Function.from(rhs)

    let contextLhs = functionLhs.contextWrapper?.pointee.context
    let contextRhs = functionRhs.contextWrapper?.pointee.context

    return functionLhs.address == functionRhs.address && contextLhs == contextRhs
}
