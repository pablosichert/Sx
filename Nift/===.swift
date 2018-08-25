func === <Arguments, Return>(
    lhs: (Arguments) -> Return,
    rhs: (Arguments) -> Return
) -> Bool {
    return equal(lhs, rhs)
}
