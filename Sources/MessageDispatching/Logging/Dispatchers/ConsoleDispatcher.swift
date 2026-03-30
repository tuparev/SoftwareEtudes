//
//  ConsoleDispatcher.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 16.06.25.
//

import Foundation
import SoftwareEtudesCoreMessageDispatching

/// A simple console-only dispatcher that formats and prints `Message`s.
public final class ConsoleDispatcher: MessageDispatching {
    
    // MARK: MessageDispatching
    public var dispatcherDelegate: MessageDispatchingDelegate?

    
    /// Create with an optional format template and a set of priorities to handle.
    /// - Parameters:
    ///   - template: A format string supporting {timestamp}, {date}, {time}, {level}, {message}, {code}, {thread}.
    ///   - priorities: The set of message priorities this dispatcher will print.
    ///   - enableColors: Whether to use ANSI colour codes. Auto-detects TTY by default.
    ///   - showFullMessage: Whether to show complete multi-line messages or just the first line.
    ///   - customColors: Optional custom colour mapping for priority levels.
    ///
    public init(template: String = "[{timestamp}] {message}",
                priorities: Set<MessagePriority> = [.debug, .info, .normal, .low, .background, .high, .critical],
                enableColours: Bool? = nil,
                showFullMessage: Bool = false,
                customColours: [MessagePriority: String]? = nil) {
        self.template          = template
        self.children          = []
        self.allowedPriorities = priorities
        self.showFullMessage   = showFullMessage
        self.enableColors      = enableColours ?? Self.shouldUseColors()
        self.levelColors       = customColours ?? Self.defaultColors
    }
    
    public func nextDispatchers() -> [MessageDispatching] { children }
    public func addToNextDispatchers(_ dispatcher: MessageDispatching) { children.append(dispatcher) }
    public func removeFromNextDispatchers(_ dispatcher: MessageDispatching) {
        children.removeAll { ($0 as AnyObject) === (dispatcher as AnyObject) }
    }
    public func removeAllFromNextDispatchers() { children.removeAll() }
    
    /// Handles each message: applies filters, checks priority, renders, prints, and forwards.
    ///
    public func handle(_ message: Message) async throws {
        
        // 1) Top-level filters
        if let del       = dispatcherDelegate {
            guard del.shouldDispatchMessage(message),
                  del.shouldDispatchMessageWithPriority(message.priority) else { return }
        }
        
        // 2) Priority check: only print allowed priorities
        if !allowedPriorities.contains(message.priority) {
            return
        }
        
        // 3) Prepare template variables
        let now = Date()
        let level = message.priority.description
        let body: String = {
            switch message.payload {
            case .key(let key):   return key
            case .code(let code): return "\(code)"
            }
        }()
        let code: String = {
            if case let .code(codeValue) = message.payload {
                return "\(codeValue)"
            }
            return ""
        }()
        let thread = Thread.current.name ?? (Thread.isMainThread ? "main" : "background")
        
        // 4) Render template with all supported variables
        let output = template
            .replacingOccurrences(of: "{timestamp}", with: timestampFormatter.string(from: now))
            .replacingOccurrences(of: "{date}", with: dateFormatter.string(from: now))
            .replacingOccurrences(of: "{time}", with: timeFormatter.string(from: now))
            .replacingOccurrences(of: "{level}", with: level)
            .replacingOccurrences(of: "{message}", with: body)
            .replacingOccurrences(of: "{code}", with: code)
            .replacingOccurrences(of: "{thread}", with: thread)
        
        // 5) Apply colors if enabled
        let finalOutput = enableColors ? 
            applyColor(to: output, priority: message.priority) : output
        
        // 6) Thread-safe print with destination selection
        let destination = message.priority >= .critical ? 
            FileHandle.standardError : FileHandle.standardOutput
        
        printQueue.async {
            self.printToDestination(finalOutput, destination: destination)
        }

        // 6) Forward to downstream
        for child in children {
            try await child.handle(message)
        }
    }
    
    // MARK: MessageDispatching
    private var children: [MessageDispatching]
    
    /// A format string supporting multiple placeholder variables.
    private let template: String
    
    /// The set of priorities this dispatcher will print.
    private let allowedPriorities: Set<MessagePriority>
    
    /// Whether to show complete multi-line messages.
    private let showFullMessage: Bool
    
    /// Whether ANSI colors are enabled.
    private let enableColors: Bool
    
    /// Map each priority to an ANSI colour code.
    private let levelColors: [MessagePriority: String]
    
    /// Thread-safe printing queue.
    private let printQueue = DispatchQueue(label: "console.dispatcher", qos: .utility)
    
    /// Formatters for timestamp rendering (lazy for performance).
    private lazy var timestampFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()
    
    /// Default ANSI colour mapping.
    private static let defaultColors: [MessagePriority: String] = [
        .debug:    "\u{001B}[0;36m", // cyan
        .info:     "\u{001B}[0;32m", // green
        .normal:   "\u{001B}[0;37m", // white
        .low:      "\u{001B}[0;34m", // blue
        .background:"\u{001B}[0;90m",// bright black (dim)
        .high:     "\u{001B}[0;33m", // yellow
        .critical: "\u{001B}[0;31m", // red
    ]
    
    private static let resetColor = "\u{001B}[0;0m"
    
    /// Auto-detect if colours should be used (TTY + environment detection).
    private static func shouldUseColors() -> Bool {
        guard isatty(STDOUT_FILENO) != 0 else { return false }
        let term = ProcessInfo.processInfo.environment["TERM"] ?? ""
        return !term.isEmpty && term != "dumb"
    }
    
    /// Apply colour formatting to output based on priority.
    private func applyColor(to output: String, priority: MessagePriority) -> String {
        let colour = levelColors[priority] ?? levelColors[.normal]!
        return colour + output + Self.resetColor
    }
    
    /// Print output to specified destination (stdout/stderr).
    private func printToDestination(_ output: String, destination: FileHandle) {
        if let data = (output + "\n").data(using: .utf8) {
            destination.write(data)
        } else {
            // Fallback to regular print if encoding fails
            print(output)
        }
    }
    
    /// Manually flush any pending output (useful for testing).
    public func flush() {
        printQueue.sync {}
    }

    public func flushForTermination() async {
        flush()
    }
}
