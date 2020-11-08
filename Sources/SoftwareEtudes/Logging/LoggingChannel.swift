//
//  LoggingChannel.swift
//  
//
//  Created by Georg Tuparev on 07/11/2020.
//

import Foundation

public protocol LoggingChannelProtocol {
    var minimalLoggingLevel: LogLevel { get set }  // Default value should be `.notice`
}

public class LoggingChannel: LoggingChannelProtocol {
    public var minimalLoggingLevel: LogLevel = .notice
}
