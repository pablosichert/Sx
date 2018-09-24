public struct Operation {
    public struct Insert {
        public let mount: Any
        public let index: Int
    }

    public struct Remove {
        public let mount: Any
        public let index: Int
    }

    public struct Reorder {
        public let mount: Any
        public let from: Int
        public let to: Int
    }

    public struct Replace {
        public let old: Any
        public let new: Any
        public let index: Int
    }
}
