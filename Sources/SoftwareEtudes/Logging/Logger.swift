//
//  Logger.swift
//  
//
//  Created by Georg Tuparev on 18/10/2020.
//

import Foundation

public protocol Logging {
    var privacy: MessagePrivacy { get set }  // Default value should be `.strictlyPrivate`
    var channels: [LoggingChannelProtocol] { get }
}

/// Simple logger that has a single default channel that prints all logs of all levels to the console using print().
/// In most cases there is no need to override or reimplement this logger. Configuring channels and privacy levels
/// will be sufficient for most uses. Note that once this ligger is finished, it will send logs asynchronously (in a
/// background thread) and will try to be as optimal as system signposts.
public class Logger: Logging {
    public var privacy: MessagePrivacy = .sensitive
    public var channels = [LoggingChannelProtocol]()

    public init() {
        let channel = LoggingChannel()
        channel.minimalLoggingLevel = .trace
        channels.append(channel)
    }
}
