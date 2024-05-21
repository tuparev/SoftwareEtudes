//
//  PrettyJson+AdditionsTests.swift
//
//
//  Created by Zhanna on 16.05.24.
//
//      1. Zhanna Hakobyan - see CONTRIBUTORS
//

import Foundation
import XCTest
@testable import SoftwareEtudesUtilities

private struct MockObject: Codable, JSONable {
    typealias `Type` = MockObject
    
    var value     : String
    var subObject : MockSubObject
}

private struct MockSubObject: Codable, JSONable {
    typealias `Type` = MockSubObject
    
    var subValue: String
}

final class JSONableTests: XCTestCase {
    
    func test_decode_withValidJson() {
        let json   =  "{\n  \"value\" : \"test1\",\n  \"subObject\" : {\n  \"subValue\" : \"test2\"\n  }  \n}"
        let object = MockObject.fromJSON(json)
        
        XCTAssertNotNil(object)
        XCTAssertEqual (object?.value, "test1")
        XCTAssertEqual (object?.subObject.subValue, "test2")
    }
    
    func test_decode_withInvalidJson() {
        let json   = "{\n  \"subObject\" : "
        let object = MockObject.fromJSON(json)
        
        XCTAssertNil(object)
    }
    
    func test_encode_withValidJson() {
        let object = MockObject(value: "test1", subObject: .init(subValue: "test2"))
        let json   = object.toJson()
        
        XCTAssertNotNil(json)
    }
    
    func test_encode_withInvalidJson() {
        let object = MockObject(value: "test1", subObject: .init(subValue: "test2"))
        let json   = object.toJson()
        
        XCTAssertNotEqual(json, "{\n  \"subObject\" : ")
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    static var allTests = [
        ("test_decode_withValidJson",   test_decode_withValidJson),
        ("test_decode_withInvalidJson", test_decode_withInvalidJson),
        ("test_encode_withValidJson",   test_encode_withValidJson),
        ("test_encode_withInvalidJson", test_encode_withInvalidJson)
    ]
    
}
