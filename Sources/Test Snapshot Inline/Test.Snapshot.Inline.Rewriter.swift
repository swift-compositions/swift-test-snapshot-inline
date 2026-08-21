// This source file is part of the swift-test-snapshot-inline open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-test-snapshot-inline project authors
// Licensed under Apache License v2.0

internal import File_System
internal import SwiftParser
internal import SwiftSyntax
internal import SwiftSyntaxBuilder
public import Test
public import Test_Snapshot

extension Test.Snapshot.Inline {
    public enum Rewriter {}
}

extension Test.Snapshot.Inline.Rewriter {
    // swift-linter:disable:next compound identifier
    // REASON: This is the single batch counterpart to rewrite; a one-member namespace adds no seam.
    public static func writeAll(
        _ entries: [Swift.String: [Test.Snapshot.Inline.Entry]]
    ) throws(Error) {
        for (path, values) in entries {
            let file = File(File.Path(stringLiteral: path))
            let source: Swift.String
            do throws(Either<File.System.Read.Full.Error, Never>) {
                source = try file.read.full { span in
                    span.withUnsafeBufferPointer { unsafe Swift.String(decoding: $0, as: UTF8.self) }
                }
            } catch {
                throw .read(path: path, underlying: Swift.String(describing: error))
            }

            let output = try rewrite(source: source, path: path, entries: values)
            do throws(File.System.Write.Atomic.Error) {
                try file.write.atomic(output)
            } catch {
                throw .write(path: path, underlying: Swift.String(describing: error))
            }
        }
    }

    public static func rewrite(
        source: Swift.String,
        path: Swift.String,
        entries: [Test.Snapshot.Inline.Entry]
    ) throws(Error) -> Swift.String {
        let tree = Parser.parse(source: source)
        let converter = SourceLocationConverter(fileName: path, tree: tree)
        let syntax = Syntax(
            entries: entries.sorted {
                ($0.line, $0.column) < ($1.line, $1.column)
            },
            converter: converter
        )
        let rewritten = syntax.visit(tree)
        if let missing = syntax.missing {
            throw .callSite(path: path, line: missing.line, column: missing.column)
        }
        return rewritten.description
    }
}

extension Test.Snapshot.Inline.Rewriter {
    private final class Syntax: SyntaxRewriter {
        let entries: [Test.Snapshot.Inline.Entry]
        let converter: SourceLocationConverter
        private var index = 0

        init(entries: [Test.Snapshot.Inline.Entry], converter: SourceLocationConverter) {
            self.entries = entries
            self.converter = converter
            super.init(viewMode: .sourceAccurate)
        }

        var missing: Test.Snapshot.Inline.Entry? {
            index < entries.count ? entries[index] : nil
        }

        override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
            guard index < entries.count else { return super.visit(node) }
            let entry = entries[index]
            let location = node.startLocation(converter: converter)
            guard location.line == entry.line, location.column == entry.column else {
                return super.visit(node)
            }
            let name = node.calledExpression.trimmedDescription
            guard name == "snapshot" || name == "assert" || name.hasSuffix(".assert") else {
                return super.visit(node)
            }
            index += 1
            return super.visit(apply(entry.actual, to: node))
        }
    }
}

private func apply(
    _ value: Swift.String,
    to node: FunctionCallExprSyntax
) -> FunctionCallExprSyntax {
    let indent = indentation(of: node)
    let closure = snapshotClosure(value: value, indent: indent)
    var updated = node.with(
        \.additionalTrailingClosures,
        node.additionalTrailingClosures.filter { $0.label.text != "matches" }
    )
    let matches = MultipleTrailingClosureElementSyntax(
        leadingTrivia: .space,
        label: .identifier("matches"),
        colon: .colonToken(trailingTrivia: .space),
        closure: closure.with(\.leadingTrivia, [])
    )
    updated = updated.with(
        \.additionalTrailingClosures,
        updated.additionalTrailingClosures + [matches]
    )
    return updated
}

private func snapshotClosure(value: Swift.String, indent: Swift.String) -> ClosureExprSyntax {
    let inner = indent + "    "
    let hashes = Swift.String(repeating: "#", count: hashCount(for: value))
    let content = value
        .split(separator: "\n", omittingEmptySubsequences: false)
        .map { $0.isEmpty ? Swift.String($0) : inner + $0 }
        .joined(separator: "\n")
    let literal = value.isEmpty
        ? "\(hashes)\"\"\"\n\(inner)\(hashes)\"\"\""
        : "\(hashes)\"\"\"\n\(content)\n\(inner)\(hashes)\"\"\""
    return ClosureExprSyntax(
        leadingTrivia: .space,
        leftBrace: .leftBraceToken(),
        statements: CodeBlockItemListSyntax([
            CodeBlockItemSyntax(
                leadingTrivia: .newline + .spaces(inner.count),
                item: .expr(ExprSyntax(stringLiteral: literal))
            )
        ]),
        rightBrace: .rightBraceToken(leadingTrivia: .newline + .spaces(indent.count))
    )
}

private func indentation(of node: some SyntaxProtocol) -> Swift.String {
    var result = ""
    for piece in node.leadingTrivia.pieces {
        switch piece {
        case .spaces(let count): result = Swift.String(repeating: " ", count: count)
        case .tabs(let count): result = Swift.String(repeating: "\t", count: count)
        default: break
        }
    }
    return result
}

private func hashCount(for value: Swift.String) -> Int {
    var hashes = 0
    while value.contains("\"\"\"" + Swift.String(repeating: "#", count: hashes))
        || value.contains("\\" + Swift.String(repeating: "#", count: hashes) + "(")
    {
        hashes += 1
    }
    return hashes
}
