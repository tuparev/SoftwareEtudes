//
//  Logger.swift
//  
//
//  Created by Georg Tuparev on 18/10/2020.
//

import Foundation

public protocol Logging: class {
    static func setDefaultLogger(_ logger: Logging)

    var privacy: MessagePrivacy { get set }  // Default value should be `.strictlyPrivate`
    var channels: [LoggingChannelProtocol] { get }
    var domain: String { get }

    init(domain: String)

    func log(_ log: Logging)
}

/// Simple logger that has a single default channel that prints all logs of all levels to the console using print().
/// In most cases there is no need to override or reimplement this logger. Configuring channels and privacy levels
/// will be sufficient for most uses. Note that once this ligger is finished, it will send logs asynchronously (in a
/// background thread) and will try to be as optimal as system signposts.
@available(OSX 10.12, *, iOS 10.13, *, tvOS 10.0, *, watchOS 4.0, *)
public class Logger: Logging {

    //TODO: Properly configure the default logger as a console logger!
    private static var _defaultLogger: Logging!
    public static func setDefaultLogger(_ logger: Logging) { _defaultLogger = logger }

    public var privacy: MessagePrivacy = .sensitive
    public var channels = [LoggingChannelProtocol]()
    public var domain: String

    required public init(domain: String) {
        self.domain = domain
        self.loggingQueue = DispatchQueue(label: domain, qos: .utility)
    }


    public func log(_ log: Logging) {
        os_unfair_lock_lock(&unfairLock)

        logQueue.append(log)
        if !isFlushing { flush() }

        os_unfair_lock_unlock(&unfairLock)
    }

    private var unfairLock = os_unfair_lock_s()
    private var logQueue = [Logging]()
    private var isFlushing = false
    private let loggingQueue: DispatchQueue!

    private func flush() {
        isFlushing = true
        defer { isFlushing = false }

        while !logQueue.isEmpty {
            let log = loggingQueue.sync { return logQueue.removeFirst() }

            loggingQueue.async {
                do {
                    for channel in self.channels {
                        try channel.dispatch(log: log as! Logable)
                    }
                }
                catch { self.logQueue.append(log) }
            }
        }
    }
}
