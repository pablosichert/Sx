func replace(
    new: NodeInstance,
    old: NodeInstance,
    insert: Insert,
    remove: Remove,
    replace: Replace
) -> Int {
    let mountsOld = old.mount()
    let old = old.index ..< old.index + mountsOld.count

    let mountsNew = new.mount()
    let new = new.index ..< new.index + mountsNew.count

    let leadingOld: CountableRange<Int>
    let trailingOld: CountableRange<Int>

    let shared = old.clamped(to: new)

    let leadingNew: CountableRange<Int>
    let trailingNew: CountableRange<Int>

    if shared.count > 0 {
        leadingOld = old.lowerBound ..< shared.lowerBound
        trailingOld = shared.upperBound ..< old.upperBound

        leadingNew = new.lowerBound ..< shared.lowerBound
        trailingNew = shared.upperBound ..< new.upperBound
    } else {
        leadingOld = old
        trailingOld = old.upperBound ..< old.upperBound

        leadingNew = new
        trailingNew = new.upperBound ..< new.upperBound
    }

    for i in leadingOld {
        remove((mount: mountsOld[i - leadingOld.lowerBound], index: i))
    }

    for i in leadingNew {
        insert((mount: mountsNew[i - leadingNew.lowerBound], index: i))
    }

    for i in shared {
        replace((
            old: mountsOld[leadingOld.count + i - shared.lowerBound],
            new: mountsNew[leadingNew.count + i - shared.lowerBound],
            index: i
        ))
    }

    for i in trailingOld {
        remove((
            mount: mountsOld[leadingOld.count + shared.count + i - trailingOld.lowerBound],
            index: i
        ))
    }

    for i in trailingNew {
        insert((
            mount: mountsNew[leadingNew.count + shared.count + i - trailingNew.lowerBound],
            index: i
        ))
    }

    return mountsNew.count
}
