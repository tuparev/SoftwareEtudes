import Logging

// Create a logger instance
let logger = Logging.Logger(label: "com.example.app")

// Log messages at different levels
logger.debug("Debug information")
logger.info("Application started")
logger.warning("Warning message")
logger.error("An error occurred")
logger.critical("Critical failure!")

