import SoftwareEtudesCoreMessageDispatching
import SoftwareEtudesLogging

// Create a priority filter delegate
class PriorityFilter: MessageDispatchingDelegate {
    var allowedPriorities: [MessagePriority] = []
    
    func shouldDispatchMessage(_ message: Message) -> Bool {
        return true
    }
    
    func shouldDispatchMessageWithPriority(_ priority: MessagePriority) -> Bool {
        return allowedPriorities.contains(priority)
    }
}

// Apply filter to dispatcher
let filter = PriorityFilter()
filter.allowedPriorities = [.high, .critical]

let fileDispatcher = try FileDispatcher(fileURL: logURL)
fileDispatcher.dispatcherDelegate = filter

// Now only high and critical messages will be written to file

