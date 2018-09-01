func intersect<T>(
    _ a: CountableRange<T>,
    _ b: CountableRange<T>
) -> CountableRange<T>? {
    let lowerBoundMax = max(a.lowerBound, b.lowerBound)
    let upperBoundMin = min(a.upperBound, b.upperBound)

    let lowerBeforeUpper = lowerBoundMax <= a.upperBound && lowerBoundMax <= b.upperBound
    let upperBeforeLower = upperBoundMin >= a.lowerBound && upperBoundMin >= b.lowerBound

    if lowerBeforeUpper && upperBeforeLower {
        return lowerBoundMax ..< upperBoundMin
    } else {
        return nil
    }
}
