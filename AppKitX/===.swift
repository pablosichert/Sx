import func Nift.compare

func === <Arguments, Return>(
    lhs: @escaping (Arguments) -> Return,
    rhs: @escaping (Arguments) -> Return
) -> Bool {
    return compare(lhs, rhs)
}
