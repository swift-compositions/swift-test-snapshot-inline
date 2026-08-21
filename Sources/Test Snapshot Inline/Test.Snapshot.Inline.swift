//
//  Test.Snapshot.Inline.swift
//  swift-test-primitives
//
//  Inline snapshot testing namespace.
//

extension Test.Snapshot {
    /// Namespace for inline snapshot testing types.
    ///
    /// Inline snapshots embed expected values directly in test source
    /// as trailing closures, with automatic source rewriting on first
    /// run or in record mode.
    public enum Inline {}
}
