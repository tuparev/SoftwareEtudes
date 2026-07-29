//
//  ConfigurationDomain.swift
//  
//
//  Created by Georg Tuparev on 15/01/2024.
//  Copyright © See Framework's LICENSE file
//

import Foundation

public protocol ConfigurationDomainProtocol {

}
open class ConfigurationDomain: ConfigurationDomainProtocol {

    public var name: String

    public init(name: String) {
        self.name = name
    }

}
