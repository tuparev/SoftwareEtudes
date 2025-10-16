import Foundation
import SoftwareEtudesLogging

// Create network dispatcher
let endpoint = URL(string: "https://logs.example.com/api/logs")!
let networkDispatcher = NetworkDispatcher(
    endpoint: endpoint,
    session: URLSession.shared
)

// Bootstrap with network dispatcher
let handler = Logger(dispatchers: [networkDispatcher])
LoggingSystem.bootstrap { _ in handler }

// Messages are batched and sent automatically
// Manually flush if needed
await networkDispatcher.flush()

