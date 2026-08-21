// This source file is part of the swift-test-snapshot-inline open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-test-snapshot-inline project authors
// Licensed under Apache License v2.0

public import Test
public import Test_Snapshot

extension Test.Snapshot.Inline.Rewriter {
    public enum Error: Swift.Error, Sendable {
        case read(path: Swift.String, underlying: Swift.String)
        case write(path: Swift.String, underlying: Swift.String)
        case callSite(path: Swift.String, line: Int, column: Int)
    }
}
