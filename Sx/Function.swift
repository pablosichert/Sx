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

public struct Function {
    private let unknown0: UnsafePointer<Any>
    private let unknown1: UnsafePointer<Any>
    private let address: UnsafePointer<Any>
    private let contextWrapper: UnsafePointer<ContextWrapper>?

    public static func from<Arguments, Return>(
        _ function: @escaping (Arguments) -> Return
    ) -> Function {
        return unsafeBitCast(function, to: FunctionWrapper.self).function.pointee
    }
}

extension Function: Equatable {
    public static func == (lhs: Function, rhs: Function) -> Bool {
        let contextLhs = lhs.contextWrapper?.pointee.context
        let contextRhs = rhs.contextWrapper?.pointee.context

        return lhs.address == rhs.address && contextLhs == contextRhs
    }
}
