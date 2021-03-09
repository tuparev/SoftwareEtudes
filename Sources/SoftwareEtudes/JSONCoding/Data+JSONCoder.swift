//
//  Data+JSONCoder.swift
//
//  Created by Georg Tuparev on 08/03/2021.
//  Copyright © 2021 Tuparev Technologies. All rights reserved.
//

import Foundation

public extension Data {

    func decode<T: Decodable>(_ type: T.Type, jsonCoder: JSONCoderWell = JSONCoderWell.default) throws -> T {
        let decoder = jsonCoder.decoder
        let loaded  = try decoder.decode(T.self, from: self)

        return loaded
    }

    static func encode<T: Encodable>(_ encodable: T, jsonCoder: JSONCoderWell = JSONCoderWell.default) throws -> Data {
        let encoder = jsonCoder.encoder

        return try encoder.encode(encodable)
    }

}
