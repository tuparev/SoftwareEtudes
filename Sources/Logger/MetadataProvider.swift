//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Logging API open source project
//
// Copyright (c) 2018-2022 Apple Inc. and the Swift Logging API project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift Logging API project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

#if canImport(Darwin)
import Darwin
#endif

@preconcurrency protocol _SwiftLogSendable: Sendable {}

extension Logger {
    /// A `MetadataProvider` is used to automatically inject runtime-generated metadata
    /// to all logs emitted by a logger.
    ///
    /// ### Example
    /// A metadata provider may be used to automatically inject metadata such as
    /// trace IDs:
    ///
    /// ```swift
    /// import Tracing // https://github.com/apple/swift-distributed-tracing
    ///
    /// let metadataProvider = MetadataProvider {
    ///     guard let traceID = Baggage.current?.traceID else { return nil }
    ///     return ["traceID": "\(traceID)"]
    /// }
    /// let logger = Logger(label: "example", metadataProvider: metadataProvider)
    /// var baggage = Baggage.topLevel
    /// baggage.traceID = 42
    /// Baggage.withValue(baggage) {
    ///     logger.info("hello") // automatically includes ["traceID": "42"] metadata
    /// }
    /// ```
    ///
    /// We recommend referring to [swift-distributed-tracing](https://github.com/apple/swift-distributed-tracing)
    /// for metadata providers which make use of its tracing and metadata propagation infrastructure. It is however
    /// possible to make use of metadata providers independently of tracing and instruments provided by that library,
    /// if necessary.
    public struct MetadataProvider: _SwiftLogSendable {
        /// Provide ``Logger.Metadata`` from current context.
        @usableFromInline
        internal let _provideMetadata: @Sendable() -> Metadata

        /// Create a new `MetadataProvider`.
        ///
        /// - Parameter provideMetadata: A closure extracting metadata from the current execution context.
        public init(_ provideMetadata: @escaping @Sendable() -> Metadata) {
            self._provideMetadata = provideMetadata
        }

        /// Invoke the metadata provider and return the generated contextual ``Logger/Metadata``.
        public func get() -> Metadata {
            return self._provideMetadata()
        }
    }
}
