# Test Snapshot Inline

[![CI](https://github.com/swift-foundations/swift-test-snapshot-inline/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-foundations/swift-test-snapshot-inline/actions/workflows/ci.yml)

The inline specialization of Test Snapshot: explicit recording policy, actor-isolated pending edits, neutral issue mapping, and SwiftSyntax source rewriting.

```swift
import Test_Snapshot_Inline

await Test.Snapshot.Inline.assert(
    as: .lines,
    recorder: recorder
) {
    render(subject)
} matches: {
    """
    expected output
    """
}
```

Inline Snapshot is an explicit dependency because it is the test stack's sole SwiftSyntax host. It has no Test Apple, Benchmark, concrete Clock, concrete Memory, HTML, Console, or reporter product edge. Canonical File System currently contributes a broader resolved package graph; that prerequisite release-boundary issue is tracked separately from this target's declared ownership.

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
