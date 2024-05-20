//
//  PrettyJson.swift
//
//
//  Created by Georg Tuparev on 30/04/2024.
//  Copyright © See Framework's LICENSE file
//

import Foundation

// These are simple subclasses of the system provided JSON Decoder and Encoder
// that require the dates to be in ISO8601 format and produce well formatted
// and human readable JSON outputs.

/// An extension of `JSONDecoder` that adds ISO8601 date conformance.
///
///  Most JSON data use ISO8601 dates. So, let's make it a default
public class PrettyJSONDecoder: JSONDecoder {

    /// Ensures that dates are in ISO8601 format
    public override init() {
        super.init()

        dateDecodingStrategy = .custom{ (decoder) -> Date in
            let container  = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let date       = PrettyJSONDecoder.polisDateFormatter.date(from: dateString)

            if let date = date { return date }
            else               { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date values must be ISO8601 formatted") }
        }
    }

    /// This date formatter should be used for all Pretty JSON data
    private static let polisDateFormatter = ISO8601DateFormatter()

}

/// An extension of `JSONEncoder` that adds ISO8601 date conformance and produces human readable
/// JSON files.
public class PrettyJSONEncoder: JSONEncoder {

    /// Ensures that dates are in ISO8601 format and the JSON files are human readable
    public override init() {
        super.init()

        self.dateEncodingStrategy = .iso8601
        self.outputFormatting     = .prettyPrinted
    }
}


/// `JSONable` is protocol for extending system provided JSON Decoder and Encoder
protocol JSONable {
    associatedtype `Type`: Decodable
    
    func toJson()                          -> String?
    static func fromJSON(_ string: String) -> `Type`?
}

/// The extension implements `fromJSON` method  of the `JSONable` protocol
extension JSONable {
    /// Converts the json string to `Type` instance
    static func fromJSON(_ string: String) -> `Type`? {
        let decoder = PrettyJSONDecoder()
        
        do {
            let data   = string.data(using: .utf8)!
            let result = try decoder.decode(`Type`.self, from: data)
            
            return result
        } catch { return nil }
    }
}

/// The extension of the `Encodable` where instance is `JSONable`
extension Encodable where Self: JSONable {
    /// Converts the instance to json string
    func toJson() -> String? {
        let encoder = PrettyJSONEncoder()
        
        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8)
        } catch { return nil }
    }
}
