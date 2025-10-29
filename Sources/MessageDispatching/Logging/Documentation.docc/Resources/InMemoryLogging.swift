import SoftwareEtudesLogging
import SoftwareEtudesCoreMessageDispatching
import Logging

// Create an in-memory dispatcher (bounded buffer)
let inMemoryDispatcher = InMemoryDispatcher(capacity: 200)

// Bootstrap swift-log with SoftwareEtudes logger and the in-memory dispatcher
let handler = Logger(dispatchers: [inMemoryDispatcher])
LoggingSystem.bootstrap { _ in handler }

// Later, query logs or clear them
Task {
    let allLogs = await inMemoryDispatcher.getAllLogs()
    let criticalLogs = await inMemoryDispatcher.filterLogs(by: .critical)
    let searchHits = await inMemoryDispatcher.searchLogs(text: "database")

    // Clear when needed
    await inMemoryDispatcher.clear()
}


