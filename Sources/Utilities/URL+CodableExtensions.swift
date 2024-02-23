//
//  URL+CodableExtensions.swift
//
//
//  Created by Georg Tuparev on 23/08/2023.
//  Copyright © See Framework's LICENSE file
//
//  Contributions, suggestions, ideas by:
//    1. <anonymous> - This code is from the wide, wide net. I (Georg) tried to
//    find the original source, but I was unable to do so. Many thanks to the
//    super kind person, who suggested how to decode URLs properly.


import Foundation

extension KeyedDecodingContainer {
    func decode(_ type: URL.Type, forKey key: K) throws -> URL {
        let string = try decode(String.self, forKey: key)
        guard let url = URL(string: string.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? "")
        else {
            throw DecodingError.dataCorrupted(.init(codingPath: codingPath, 
                                                    debugDescription: "The string value for the key \(key) couldn't be converted into a URL value: \(string)"))
        }
        return url
    }

    // ... and if the URL is optional
    func decodeIfPresent(_ type: URL.Type, forKey key: K) throws -> URL? {
        try URL(string: decode(String.self, forKey: key).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? "")
    }
}
