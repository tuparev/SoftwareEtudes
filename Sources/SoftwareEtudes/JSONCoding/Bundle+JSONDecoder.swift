//
//  Bundle+JSONDecoder.swift
//  
//  Created by Georg Tuparev on 08/03/2021.
//  Copyright © 2021 Tuparev Technologies. All rights reserved.
//

import Foundation

public extension Bundle {

    func decode<T: Decodable>(_ type: T.Type,
                              forResource: String,
                              withExtension: String?,
                              jsonCoder: JSONCoderWell = JSONCoderWell.default) throws -> T? {
        let ext     = withExtension ?? "json"
        let decoder = jsonCoder.decoder

        guard let url = self.url(forResource: forResource, withExtension: ext) else { return nil }

        let data   = try Data(contentsOf: url)
        let loaded = try decoder.decode(T.self, from: data)

        return loaded
    }
}
