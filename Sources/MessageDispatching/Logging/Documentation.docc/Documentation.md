# ``SoftwareEtudesLogging``

A flexible, high-performance logging framework for Swift that integrates with Apple's swift-log.

## Overview

The SoftwareEtudes Logging Framework provides multiple dispatch targets with priority-based filtering, message batching, and thread-safe operations.

**Key Features:**
- Multiple dispatch targets (Console, File, Network, OSLog)
- Priority-based filtering
- Message batching for performance
- Thread-safe operations with Swift concurrency
- Automatic retry logic for network failures

## Topics

### Essentials

- ``Logger``
- ``Log``

### Dispatchers

- ``ConsoleDispatcher``
- ``FileDispatcher``
- ``NetworkDispatcher``
- ``OSLogDispatcher``
- ``InMemoryDispatcher``

### Tutorials

- <doc:LoggingGuide>
