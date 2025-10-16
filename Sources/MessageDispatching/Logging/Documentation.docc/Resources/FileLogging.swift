import Foundation
import SoftwareEtudesLogging

// Create log file URL
let logURL = FileManager.default
    .urls(for: .documentDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("app.log")

// Create file dispatcher with rotation
let fileDispatcher = try FileDispatcher(
    fileURL: logURL,
    maxFileSize: 10 * 1024 * 1024,  // 10 MB
    maxBackupCount: 5                // Keep 5 rotated files
)

// Bootstrap with file dispatcher
let handler = Logger(dispatchers: [fileDispatcher])
LoggingSystem.bootstrap { _ in handler }

