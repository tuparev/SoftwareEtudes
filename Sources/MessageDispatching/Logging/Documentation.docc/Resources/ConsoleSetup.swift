import SoftwareEtudesLogging

// Create a console dispatcher with colour support
let consoleDispatcher = ConsoleDispatcher(
    priorities: [.debug, .info, .normal, .high, .critical],
    showFullMessage: true,
    enableColours: true
)

