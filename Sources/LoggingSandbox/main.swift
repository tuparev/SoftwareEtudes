//
//  main.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 11.11.25.
//

import Foundation
import Logging
import SoftwareEtudesLogging
import SoftwareEtudesCoreMessageDispatching

@main
struct LoggingSandboxCLI {
    static func main() async {
        let context = bootstrapLogger()
        let logger  = context.logger
        
        print("\n=== SoftwareEtudes Logging Sandbox ===\n")
        
        // Demonstrate all log levels
        await demonstrateLogLevels(logger: logger)
        
        // Demonstrate metadata
        await demonstrateMetadata(logger: logger)
        
        // Demonstrate error scenarios
        await demonstrateErrors(logger: logger)
        
        // Give dispatchers time to process
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Flush console output
        context.console.flush()
        
        // Display summary
        await displaySummary(inMemory: context.inMemory)
        
        print("\n=== Sandbox Complete ===\n")
    }

    private static func bootstrapLogger() -> (logger: Logging.Logger, console: ConsoleDispatcher,
        inMemory: InMemoryDispatcher) {
        
        let consoleDispatcher  = ConsoleDispatcher()
        let inMemoryDispatcher = InMemoryDispatcher(capacity: 50)

        let sandboxHandler     = SoftwareEtudesLogging.Logger(
            logLevel: .trace,
            metadata: ["subsystem": "LoggingSandbox"],
            dispatchers: [
                consoleDispatcher,
                inMemoryDispatcher
            ]
        )

        LoggingSystem.bootstrap { _ in sandboxHandler }
        let logger             = Logging.Logger(label: "com.softwareetudes.logging-sandbox")

        return (logger: logger, console: consoleDispatcher, inMemory: inMemoryDispatcher)
    }
    
    // MARK: - Demonstration Functions
    
    private static func demonstrateLogLevels(logger: Logging.Logger) async {
        print("📊 Demonstrating all log levels...\n")
        
        logger.trace("This is a TRACE message - finest grain debugging")
        logger.debug("This is a DEBUG message - general debugging info")
        logger.info("This is an INFO message - informational updates")
        logger.notice("This is a NOTICE message - normal but significant")
        logger.warning("This is a WARNING message - something to watch")
        logger.error("This is an ERROR message - something went wrong")
        logger.critical("This is a CRITICAL message - system failure!")
        
        print("")
    }
    
    private static func demonstrateMetadata(logger: Logging.Logger) async {
        print("🏷️  Demonstrating metadata...\n")
        
        var loggerWithMetadata = logger
        loggerWithMetadata[metadataKey: "userId"] = "12345"
        loggerWithMetadata[metadataKey: "sessionId"] = "abc-def-ghi"
        
        loggerWithMetadata.info("User logged in", metadata: [
            "username": "john.doe",
            "loginMethod": "oauth"
        ])
        
        loggerWithMetadata.info("User performed action", metadata: [
            "action": "file.upload",
            "fileSize": "2048",
            "fileName": "document.pdf"
        ])
        
        print("")
    }
    
    private static func demonstrateErrors(logger: Logging.Logger) async {
        print("⚠️  Demonstrating error scenarios...\n")
        
        // Simulate an error
        enum DemoError: Error {
            case networkTimeout
            case invalidData
        }
        
        do {
            throw DemoError.networkTimeout
        } catch {
            logger.error("Network operation failed", metadata: [
                "error": "\(error)",
                "endpoint": "/api/users",
                "retryCount": "3"
            ])
        }
        
        logger.critical("Database connection lost", metadata: [
            "host": "db.example.com",
            "port": "5432",
            "lastHeartbeat": "\(Date())"
        ])
        
        print("")
    }
    
    private static func displaySummary(inMemory: InMemoryDispatcher) async {
        print("\n📋 Captured Logs Summary\n")
        print("=" + String(repeating: "=", count: 50))
        
        let allLogs = await inMemory.getAllLogs()
        print("Total messages captured: \(allLogs.count)")
        
        // Count by priority
        let priorityCounts: [MessagePriority: Int] = allLogs.reduce(into: [:]) { counts, message in
            counts[message.priority, default: 0] += 1
        }
        
        print("\nBreakdown by priority:")
        for priority in [MessagePriority.debug, .info, .normal, .high, .critical].sorted(by: { $0.rawValue < $1.rawValue }) {
            if let count = priorityCounts[priority] {
                print("  \(priority.description.padding(toLength: 12, withPad: " ", startingAt: 0)): \(count)")
            }
        }
        
        // Show sample messages
        print("\nSample captured messages:")
        for (index, message) in allLogs.prefix(3).enumerated() {
            print("  [\(index + 1)] Priority: \(message.priority.description)")
            if case .key(let key) = message.payload {
                print("      Message: \(key)")
            }
            if let args = message.arguments, !args.isEmpty {
                print("      Arguments: \(args.count) key(s)")
            }
        }
        
        print("=" + String(repeating: "=", count: 50))
    }
}
