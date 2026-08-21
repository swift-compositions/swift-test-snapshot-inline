// This source file is part of the swift-test-snapshot-inline open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-test-snapshot-inline project authors
// Licensed under Apache License v2.0

public import Test
public import Test_Snapshot

extension Test.Snapshot.Inline {
    public struct Configuration: Sendable {
        public let recording: Test.Snapshot.Recording
        public let state: State

        public init(
            recording: Test.Snapshot.Recording = .missing,
            state: State = .init()
        ) {
            self.recording = recording
            self.state = state
        }
    }
}

extension Test.Snapshot.Inline.Configuration {
    @TaskLocal public static var current = Self()
}
