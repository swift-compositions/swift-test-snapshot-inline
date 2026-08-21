// This source file is part of the swift-test-snapshot-inline open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-test-snapshot-inline project authors
// Licensed under Apache License v2.0

public import Snapshot
internal import Source_Primitives
public import Test
public import Test_Snapshot

extension Test.Snapshot.Inline {
    @discardableResult
    public static func assert<Input: Sendable>(
        as strategy: Snapshot.Strategy<Input, Swift.String>,
        recording: Test.Snapshot.Recording = Configuration.current.recording,
        state: State = Configuration.current.state,
        recorder: Test.Recorder,
        fileID: Swift.String = #fileID,
        filePath: Swift.String = #filePath,
        // swift-linter:disable:next int public parameter
        // REASON: #line is an Int compiler literal; Source.Location is constructed at this boundary.
        line: Int = #line,
        // swift-linter:disable:next int public parameter
        // REASON: #column is an Int compiler literal; Source.Location is constructed at this boundary.
        column: Int = #column,
        function: Swift.String = #function,
        _ input: () -> Input,
        matches expected: (() -> Swift.String)? = nil
    ) async -> Result {
        let source = Source.Location(
            fileID: fileID,
            filePath: filePath,
            line: line,
            column: column
        )
        let result = await verify(
            input(),
            as: strategy,
            matches: expected?(),
            recording: recording,
            state: state,
            source: source,
            function: function,
            line: line,
            column: column
        )
        if case .failed(let summary, let difference) = result {
            recorder(.init(kind: .assertion, message: .init(summary), source: source))
            if let difference {
                recorder.record(.init(name: "inline-snapshot.diff.txt", text: difference.description))
            }
        }
        return result
    }
}
