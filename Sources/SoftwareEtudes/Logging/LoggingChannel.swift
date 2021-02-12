//
//  LoggingChannel.swift
//  
//
//  Created by Georg Tuparev on 07/11/2020.
//

import Foundation

public protocol LoggingChannelProtocol: class {
    var minimalLoggingLevel: LogLevel { get set }  // Default value should be `.notice`
    var maximumLoggingLevel: LogLevel { get set }  // Default value should be `.critical`

    init(minimalLoggingLevel: LogLevel, maximumLoggingLevel: LogLevel)

    func dispatch(log: Logable) throws
    func shouldDispatch(log: Logable) -> Bool
}


/// `LoggingChannel` is an abstract class that should be overridden with one exception - if the channel is equivalent
/// to dev null (e.g. noting is ever logged).
public class LoggingChannel: LoggingChannelProtocol {
    public var minimalLoggingLevel: LogLevel
    public var maximumLoggingLevel: LogLevel

    required public init(minimalLoggingLevel: LogLevel = .notice, maximumLoggingLevel: LogLevel = .critical) {
        self.minimalLoggingLevel = minimalLoggingLevel
        self.maximumLoggingLevel = maximumLoggingLevel
    }

    public func dispatch(log: Logable) throws { }

    public func shouldDispatch(log: Logable) -> Bool { return false }

}
