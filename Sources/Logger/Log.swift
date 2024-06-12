//
//  File.swift
//  
//
//  Created by Karen on 12.06.24.
//

import Foundation
import SoftwareEtudesMessages

enum LogLevel {
    case error
    case warning
}

protocol Log {
    var logLevel: LogLevel { get }
    var message: Message { get }
}
