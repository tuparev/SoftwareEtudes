//
//  PrettyJson+AdditionsTests.swift
//
//
//  Created by Zhanna on 16.05.24.
//

import Foundation
import XCTest
@testable import SoftwareEtudesUtilities

struct MockObject: Codable, JSONable {
    typealias `Type` = MockObject
    var value: String
}

final class JSONableTests: XCTestCase {
    
    func testDecodeJsonValid() {
        let json   = "{\"value\":\"test\"}"
        let object = MockObject.fromJSON(json)
        
        XCTAssertNotNil(object)
        XCTAssertEqual (object?.value, "test")
    }
    
    func testDecodeJsonInvalid() {
        let json   = "{\"value\":\"test\""
        let object = MockObject.fromJSON(json)
        
        XCTAssertNil(object)
    }
    
    func testEncodeJsonValid() {
        let object = MockObject(value: "test")
        let json   = object.toJson()
        
        XCTAssertNotNil(json)
        XCTAssertEqual (json, "{\n  \"value\" : \"test\"\n}")
    }
    
    func testEncodeJsonInvalid() {
        let object = MockObject(value: "test")
        let json   = object.toJson()
        
        XCTAssertNotEqual(json, "{\"value\":\"test\"}")
    }
}
