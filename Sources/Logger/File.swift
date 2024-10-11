//
//  File.swift
//  SoftwareEtudes
//
//  Created by Georg Tuparev on 30.07.24.
//

import Foundation
import Logging

public struct SimpleConsoleLogHandler: LogHandler {
    
    
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            return metadata[key]
        }
        set(newValue) {
            metadata[key] = newValue
        }
    }
    
    public var metadata: Logging.Logger.Metadata
    
    public var logLevel: Logging.Logger.Level
    
    public init(label: String) {
        self.metadata = [:]
        self.logLevel = .info
    }
}
