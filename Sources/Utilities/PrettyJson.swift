//
//  PrettyJson.swift
//
//
//  Created by Georg Tuparev on 30/04/2024.
//  Copyright © See Framework's LICENSE file
//
//      1. Zhanna Hakobyan - see CONTRIBUTORS
//

import Foundation

public enum DateFormatting: Sendable {
    case iso8601
    case dateAndTimeOnly            // e.g. "yyyy-MM-dd'T'HH:mm:ss"
    case formatted(DateFormatter)
}

public enum CustomDateFormatting: String {
    case dateAndTimeOnly = "yyyy-MM-dd'T'HH:mm:ss"
}

public var dateFormatterType = DateFormatting.iso8601

// These are simple subclasses of the system provided JSON Decoder and Encoder
// that require the dates to be in ISO8601 format and produce well formatted
// and human readable JSON outputs.

/// An extension of `JSONDecoder` that adds ISO8601 date conformance.
///
///  Most JSON data use ISO8601 dates. So, let's make it a default
open class PrettyJSONDecoder: JSONDecoder, @unchecked Sendable {

    /// Ensures that dates are in ISO8601 format
    public override init() {
        super.init()

        dateDecodingStrategy = .custom{ (decoder) -> Date in
            let container  = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            var date: Date?
            switch dateFormatterType {
                case .iso8601:
                    date = ISO8601DateFormatter().date(from: dateString)
                case .dateAndTimeOnly:
                    let customFormatter = DateFormatter()
                    customFormatter.dateFormat = CustomDateFormatting.dateAndTimeOnly.rawValue
                    date = customFormatter.date(from: dateString)
               case .formatted(let formatter):
                    let customFormatter = formatter
                    date = customFormatter.date(from: dateString)
            }

            if let date = date { return date }
            else               { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date values must be ISO8601 formatted") }
        }
    }
}

/// An extension of `JSONEncoder` that adds ISO8601 date conformance and produces human readable
/// JSON files.
open class PrettyJSONEncoder: JSONEncoder, @unchecked Sendable {

    /// Ensures that dates are in ISO8601 format and the JSON files are human readable
    public override init() {
        super.init()

        switch dateFormatterType {
            case .iso8601:
                self.dateEncodingStrategy = .iso8601
            case .dateAndTimeOnly:
                let customFormatter = DateFormatter()
                customFormatter.dateFormat = CustomDateFormatting.dateAndTimeOnly.rawValue
                self.dateEncodingStrategy = .formatted(customFormatter)
            case .formatted(let formatter):
                let customFormatter = formatter
                self.dateEncodingStrategy = .formatted(customFormatter)
        }
        self.outputFormatting = .prettyPrinted
    }
}


/// `JSONAble` is protocol for extending system provided JSON Decoder and Encoder to make it easier to convert a type to ``String`` or create an instance of
/// a type from ``String``
///
/// These two operations are very common and we wonder why the standard ``Codable`` implementation does not include them.
///
/// **Note: ** Current implementation is tested only with relatively simple flat types. Perhaps for complex and nested types we will need to implement something
/// using macros, but this is a project for the future.
public protocol JSONAble {
    associatedtype `Type`: Decodable
    
    func toJson()                          -> String?
    static func fromJSON(_ string: String) -> `Type`?
}

/// The extension implements `fromJSON` method  of the `JSONA
/// ble` protocol
public extension JSONAble {

    /// Converts the JSON string into `Type` instance
    ///
    /// **Note: ** In case when the conversion is not possible the method returns `nil`. It is up to the client to handle properly these cases.
    static func fromJSON(_ string: String) -> `Type`? {
        let decoder = PrettyJSONDecoder()
        
        do {
            let data   = string.data(using: .utf8)!
            let result = try decoder.decode(`Type`.self, from: data)
            
            return result
        } catch { return nil }
    }
}

/// The extension of the `Encodable` where instance is `JSONable` adds functionality to convert any ``Encodable`` type to a well-formatted and
/// human readable string
///
/// **Note: ** to use this functionality you need to use `PrettyJSONEncoder` instead of the standard `JSONEncoder`.
public extension Encodable where Self: JSONAble {
    /// Converts the instance to json string
    func toJson() -> String? {
        let encoder = PrettyJSONEncoder()
        
        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8)
        } catch { return nil }
    }
}

public struct RemoteUncachedJSONContent<T: Decodable> {
    public init(url: URL) { self.url = url }

    private var contents: T {
        get async throws {
            let (data, _) = try await URLSession.nonCachingSession.data(from: url)

            return try PrettyJSONDecoder().decode(T.self, from: data)
        }
    }

    private let url: URL
}
