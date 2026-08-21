// This source file is part of the swift-test-snapshot-inline open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-test-snapshot-inline project authors
// Licensed under Apache License v2.0

import Snapshot
import Source_Primitives
import Test_Snapshot
import Test_Snapshot_Inline
import Testing

enum Inline {}

extension Inline {
    @Suite struct Test {
        @Suite struct Unit {
            @Test
            func `recording policy`() async {
            let state = NeutralTest.Snapshot.Inline.State()
            let source = Source.Location(
                fileID: "Fixture/Subject.swift",
                filePath: "/tmp/Subject.swift",
                line: 2,
                column: 5
            )

            let missing = await NeutralTest.Snapshot.Inline.verify(
                "actual",
                as: .lines,
                matches: nil,
                recording: .missing,
                state: state,
                source: source,
                function: "subject()",
                line: 2,
                column: 5
            )
            let failed = await NeutralTest.Snapshot.Inline.verify(
                "new",
                as: .lines,
                matches: "old",
                recording: .failed,
                state: state,
                source: source,
                function: "subject()",
                line: 3,
                column: 5
            )

            #expect(missing == .recorded)
            #expect(failed == .recorded)
            #expect(await state.drain()["/tmp/Subject.swift"]?.count == 2)
        }

            @Test
            func `concurrent registration`() async {
            let state = NeutralTest.Snapshot.Inline.State()
            await withTaskGroup(of: Void.self) { group in
                (1...32).forEach { index in
                    group.addTask {
                        await state.register(entry(actual: "\(index)", line: index))
                    }
                }
            }
            #expect(await state.drain()["/tmp/Subject.swift"]?.count == 32)
        }
    }

    @Suite struct `Edge Case` {
        @Test
        func `missing call site`() {
            #expect(throws: NeutralTest.Snapshot.Inline.Rewriter.Error.self) {
                try NeutralTest.Snapshot.Inline.Rewriter.rewrite(
                    source: "func subject() {}",
                    path: "/tmp/Subject.swift",
                    entries: [entry(actual: "value", line: 9)]
                )
            }
        }

        @Test
        func `raw multiline delimiter`() throws {
            let source = """
                func subject() {
                    Test.Snapshot.Inline.assert(as: .lines, recorder: recorder) {
                        "old"
                    }
                }
                """
            let value = "\\(value) \"\"\"#"
            let output = try NeutralTest.Snapshot.Inline.Rewriter.rewrite(
                source: source,
                path: "/tmp/Subject.swift",
                entries: [entry(actual: value, line: 2, column: 5)]
            )
            #expect(output.contains("matches:"))
            #expect(output.contains("##\"\"\""))
            #expect(output.contains(value))
        }
    }

    @Suite struct Integration {
        @Test
        func `golden rewrite`() throws {
            let source = """
                func subject() {
                    Test.Snapshot.Inline.assert(as: .lines, recorder: recorder) {
                        "old"
                    } matches: {
                        "stale"
                    }
                }
                """
            let output = try NeutralTest.Snapshot.Inline.Rewriter.rewrite(
                source: source,
                path: "/tmp/Subject.swift",
                entries: [entry(actual: "first\nsecond", line: 2, column: 5)]
            )
            #expect(output.contains("first\n        second"))
            #expect(!output.contains("stale"))
        }
    }
}
}

private func entry(
    actual: Swift.String,
    line: Int,
    column: Int = 1
) -> NeutralTest.Snapshot.Inline.Entry {
    .init(
        expected: nil,
        actual: actual,
        source: .init(
            fileID: "Fixture/Subject.swift",
            filePath: "/tmp/Subject.swift",
            line: line,
            column: column
        ),
        function: "subject()",
        line: line,
        column: column
    )
}
