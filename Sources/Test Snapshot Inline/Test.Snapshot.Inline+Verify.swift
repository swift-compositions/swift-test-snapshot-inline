// This source file is part of the swift-test-snapshot-inline open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-test-snapshot-inline project authors
// Licensed under Apache License v2.0

public import Snapshot
public import Source_Primitives
public import Test
public import Test_Snapshot

extension Test.Snapshot.Inline {
    public static func verify<Input: Sendable>(
        _ input: Input,
        as strategy: Snapshot.Strategy<Input, Swift.String>,
        matches expected: Swift.String?,
        recording: Test.Snapshot.Recording = Configuration.current.recording,
        state: State = Configuration.current.state,
        source: Source.Location,
        function: Swift.String,
        // swift-linter:disable:next int public parameter
        // REASON: SwiftSyntax SourceLocation exposes the compiler literal coordinate as Int.
        line: Int,
        // swift-linter:disable:next int public parameter
        // REASON: SwiftSyntax SourceLocation exposes the compiler literal coordinate as Int.
        column: Int
    ) async -> Result {
        let actual = await strategy.capture(input)
        let difference = expected.flatMap { strategy.comparison.difference($0, actual) }

        func register() async {
            await state.register(
                .init(
                    expected: expected,
                    actual: actual,
                    source: source,
                    function: function,
                    line: line,
                    column: column
                )
            )
        }

        switch recording {
        case .all:
            await register()
            return .recorded
        case .missing where expected == nil:
            await register()
            return .recorded
        case .failed where expected == nil || difference != nil:
            await register()
            return .recorded
        case .never, .missing, .failed:
            guard expected != nil else {
                return .failed(summary: "Inline snapshot is missing")
            }
            guard let difference else { return .matched }
            return .failed(summary: difference.summary, difference: difference)
        }
    }
}
