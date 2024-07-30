//
//  File.swift
//  SoftwareEtudes
//
//  Created by Georg Tuparev on 30.07.24.
//

import Foundation
import Logging

public struct SimpleConsoleLogHandler: LogHandler {
    public subscript(metadataKey _: String) -> Logging.Logger.Metadata.Value? {
        get {
            // ...
            return nil
        }
        set(newValue) {
            // ...
        }
    }
    
    public var metadata: Logging.Logger.Metadata
    
    public var logLevel: Logging.Logger.Level
    

}
