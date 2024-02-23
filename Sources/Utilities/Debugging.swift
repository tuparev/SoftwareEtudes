//
//  Debugging.swift
//  
//
//  Created by Georg Tuparev on 16.03.23.
//  Copyright © See Framework's LICENSE file
//
//  Thanks for contributions, suggestions, ideas by:
//      1. Hunter William Holland - see CONTRIBUTORS

import Foundation


// These functions are inspired by the great Paul Hudson and SwiftNEO


public func undefined<T>(_ message: String = "") -> T {
    fatalError("Undefined: \(message)")
}

public func notImplemented<T>(_ message: String = "") -> T {
    fatalError("Not implemented: \(message)")
}
