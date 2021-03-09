//
//  JSONCoderWell.swift
//
//  Created by Georg Tuparev on 09/03/2021.
//  Copyright © 2021 Tuparev Technologies. All rights reserved.
//

import Foundation

final public class JSONCoderWell {
    public static let `default` = JSONCoderWell()

    public var decoder = JSONDecoder()
    public var encoder = JSONEncoder()
}
