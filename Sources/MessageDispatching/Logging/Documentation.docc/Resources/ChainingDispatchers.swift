import SoftwareEtudesLogging

// Console: show everything
let console = ConsoleDispatcher()

// File: only high priority and above
let fileFilter = PriorityFilter()
fileFilter.allowedPriorities = [.high, .critical]

let file = try FileDispatcher(fileURL: logFileURL)
file.dispatcherDelegate = fileFilter

// Network: only critical
let networkFilter = PriorityFilter()
networkFilter.allowedPriorities = [.critical]

let network = NetworkDispatcher(endpoint: endpoint)
network.dispatcherDelegate = networkFilter

// Independent dispatchers with different filters
let handler = Logger(dispatchers: [console, file, network])
LoggingSystem.bootstrap { _ in handler }

// Now:
// .info     → console only
// .error    → console + file
// .critical → console + file + network

