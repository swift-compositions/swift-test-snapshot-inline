// This source file is part of the swift-test-snapshot-inline open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-test-snapshot-inline project authors
// Licensed under Apache License v2.0

internal import Source_Primitives
public import Test
public import Test_Snapshot

extension Test.Snapshot.Inline {
    /// Actor-isolated pending rewrites. Registration and draining are serialized.
    public actor State {
        private var entries: [Swift.String: [Entry]] = [:]

        public init() {}
    }
}

extension Test.Snapshot.Inline.State {
        public func register(_ entry: consuming Test.Snapshot.Inline.Entry) {
            let path = entry.source.filePath ?? entry.source.fileID
            entries[path, default: []].append(entry)
        }

        public func drain() -> [Swift.String: [Test.Snapshot.Inline.Entry]] {
            let result = entries
            entries.removeAll(keepingCapacity: true)
            return result
        }

        public var isEmpty: Bool { entries.isEmpty }

        public func flush() throws(Test.Snapshot.Inline.Rewriter.Error) {
            let pending = drain()
            do throws(Test.Snapshot.Inline.Rewriter.Error) {
                try Test.Snapshot.Inline.Rewriter.writeAll(pending)
            } catch {
                for (path, values) in pending {
                    entries[path, default: []].append(contentsOf: values)
                }
                throw error
            }
        }
}
