public struct Operation {
    public struct Insert {
        let mount: Any
        let index: Int
    }

    public struct Remove {
        let mount: Any
        let index: Int
    }

    public struct Reorder {
        let mount: Any
        let from: Int
        let to: Int
    }

    public struct Replace {
        let old: Any
        let new: Any
        let index: Int
    }
}
