//
//  TypeNameDescribable.swift
//  
//  Created by Georg Tuparev on 31/03/2020.
//  Copyright © 2020 Tuparev Technologies. All rights reserved.
//

import Foundation

/// This is a simple protocol and corresponding extension implementing it to get the type name as a variable (works with
/// both value type or reference type).
public protocol TypeNameDescribable {
    var typeName: String { get }
    static var typeName: String { get }
}

public extension TypeNameDescribable {
    var typeName: String { String(describing: Self.self) }
    static var typeName: String { String(describing: self) }
}
