// This source file is part of the swift-test-snapshot-inline open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-test-snapshot-inline project authors
// Licensed under Apache License v2.0

public import Source_Primitives
public import Test
public import Test_Snapshot

extension Test.Snapshot.Inline {
    /// One source rewrite requested by inline snapshot verification.
    public struct Entry: Sendable, Hashable {
        public let expected: Swift.String?
        public let actual: Swift.String
        public let source: Source.Location
        public let function: Swift.String
        public let line: Int
        public let column: Int

        public init(
            expected: Swift.String?,
            actual: Swift.String,
            source: Source.Location,
            function: Swift.String,
            // swift-linter:disable:next int public parameter
            // REASON: SwiftSyntax SourceLocation exposes the compiler literal coordinate as Int.
            line: Int,
            // swift-linter:disable:next int public parameter
            // REASON: SwiftSyntax SourceLocation exposes the compiler literal coordinate as Int.
            column: Int
        ) {
            self.expected = expected
            self.actual = actual
            self.source = source
            self.function = function
            self.line = line
            self.column = column
        }
    }
}
