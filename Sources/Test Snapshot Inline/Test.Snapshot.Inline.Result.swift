// This source file is part of the swift-test-snapshot-inline open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-test-snapshot-inline project authors
// Licensed under Apache License v2.0

public import Snapshot
public import Test
public import Test_Snapshot

extension Test.Snapshot.Inline {
    public enum Result: Sendable, Hashable {
        case matched
        case recorded
        case failed(summary: Swift.String, difference: Snapshot.Difference? = nil)
    }
}
