//
//  Data+JSONCoder.swift
//
//  Created by Georg Tuparev on 08/03/2021.
//  Copyright © 2021 Tuparev Technologies. All rights reserved.
//

import Foundation

public extension Data {

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        let loaded  = try decoder.decode(T.self, from: self)

        return loaded
    }

    static func encode<T: Encodable>(_ encodable: T) throws -> Data {
        let encoder = JSONEncoder()

        return try encoder.encode(encodable)
    }

}
