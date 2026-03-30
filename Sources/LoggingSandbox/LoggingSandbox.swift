//
//  LoggingSandbox.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 11.11.25.
//

import Foundation
import Logging
import SoftwareEtudesLogging
import SoftwareEtudesCoreMessageDispatching

@main
struct LoggingSandbox {
    static func main() async {
        let consoleDispatcher                        = ConsoleDispatcher()
        let inMemoryDispatcher                       = InMemoryDispatcher(capacity: 50)
        let sandboxHandler                           = SoftwareEtudesLogging.Logger(logLevel: .trace,
                                                                                    metadata:  ["subsystem":"LoggingSandbox"],
                                                                                    dispatchers: [consoleDispatcher, inMemoryDispatcher])

        LoggingSystem.bootstrap { _ in sandboxHandler }
        let logger                                   = Logging.Logger(label: "com.softwareetudes.logging-sandbox")

        print("\n=== SoftwareEtudes Logging Sandbox ===\n")

        // Log levels
        logger.trace("This is a TRACE message - finest grain debugging")
        logger.debug("This is a DEBUG message - general debugging info")
        logger.info("This is an INFO message - informational updates")
        logger.notice("This is a NOTICE message - normal but significant")
        logger.warning("This is a WARNING message - something to watch")
        logger.error("This is an ERROR message - something went wrong")
        logger.critical("This is a CRITICAL message - system failure!")

        // Metadata
        var loggerWithMetadata                       = logger
        loggerWithMetadata[metadataKey: "userId"]    = "12345"
        loggerWithMetadata[metadataKey: "sessionId"] = "abc-def-ghi"
        loggerWithMetadata.info("User logged in", metadata: ["username": "Ani.K", "loginMethod": "oauth"])
        loggerWithMetadata.info("User performed action", metadata: ["action": "file.upload", "fileSize": "2048", "fileName": "document.pdf"])

        // Errors
        enum DemoError: Error { case networkTimeout }
        do {
            throw DemoError.networkTimeout
        } catch {
            logger.error("Network operation failed", metadata: ["error": "\(error)", "endpoint": "/api/users", "retryCount": "3"])
        }
        logger.critical("Database connection lost", metadata: ["host": "db.example.com", "port": "5432", "lastHeartbeat": "\(Date())"])

        NotificationCenter.default.post(name: SoftwareEtudesLogging.Logger.willTerminateNotification, object: nil)
        
        print("\n=== Sandbox Complete ===\n")
    }
}
