import struct Foundation.UUID

public class Handler<T>: Equatable {
    public static func == (lhs: Handler<T>, rhs: Handler<T>) -> Bool {
        return lhs.id == rhs.id
    }

    public let id = UUID() // swiftlint:disable:this identifier_name
    public let function: T

    public init(_ function: T) {
        self.function = function
    }
}