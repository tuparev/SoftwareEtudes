import Logging
import SoftwareEtudesLogging

// Create logger handler with dispatchers
let handler = Logger(dispatchers: [consoleDispatcher])

// Bootstrap the logging system
LoggingSystem.bootstrap { label in
    handler
}

