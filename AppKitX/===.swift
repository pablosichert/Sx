import func Nift.equal

func === <Arguments, Return>(
    lhs: @escaping (Arguments) -> Return,
    rhs: @escaping (Arguments) -> Return
) -> Bool {
    return equal(lhs, rhs)
}
