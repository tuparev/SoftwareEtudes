//
//  File.swift
//  SoftwareEtudes
//
//  Created by Georg Tuparev on 30.07.24.
//

import Foundation
import Logging

public struct SimpleConsoleLogHandler: LogHandler {
    
    private let label: String
    public var logLevel: Logger.Level    = .info
    public var metadata: Logger.Metadata = [:]
    
    public init(label: String) {
        self.label = label
    }
    
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            return metadata[key]
        }
        set(newValue) {
            metadata[key] = newValue
        }
    }
    
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata additionalMetadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        guard self.logLevel <= level else { return }
        
        var combinedMetadata      = self.metadata
        if let additionalMetadata = additionalMetadata {
            combinedMetadata.merge(additionalMetadata, uniquingKeysWith: { _, new in new })
        }
        
        let timestamp             = Self.currentTimestamp()
        let metadataString        = combinedMetadata.isEmpty ? "" : " " + combinedMetadata.map { "\($0)=\($1)" }.joined(separator: " ")
        let logMessage            = "\(timestamp) [\(level)] \(label): \(message)\(metadataString)"
        print(logMessage)
    }
    
    private static func currentTimestamp() -> String {
        let formatter        = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }
}
