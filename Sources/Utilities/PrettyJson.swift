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


