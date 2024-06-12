//
//  File.swift
//  
//
//  Created by Karen on 12.06.24.
//

import Foundation
import SoftwareEtudesMessages

public class MessageLogger: Log {
    
    var logLevel: LogLevel
    var message: Message
    
    var name: String
    var domain: String
    var channeles = [MessageChanneling]()

    init(logLevel: LogLevel, message: Message, name: String = "", domain: String = "") {
        self.logLevel = logLevel
        self.message = message
        self.name = name
        self.domain = domain
    }
    
    @inlinable
    func logWithCode() {}
    
    @inlinable
    func logWithKey() {}
}
