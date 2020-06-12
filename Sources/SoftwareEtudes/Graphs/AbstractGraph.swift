//
//  AbstractGraph.swift
//  
//
//  Created by Georg Tuparev on 07/06/2020.
//

import Foundation

public protocol NodeProtocol: class {

    associatedtype AnyType: Equatable

    var name: String? { get }
    var element: AnyType? { get set }
    var tags: [String]? { get }

    init(with element: AnyType?, named name: String?)
}

public class Node<T>: NodeProtocol where T: Equatable {
    public typealias AnyType = T

    public var name: String?
    public var element: AnyType?
    public var tags: [String]?

    required public init(with element: AnyType?, named name: String? = nil) {
        self.element = element
        self.name = name
    }

    convenience init() {
        self.init(with: nil, named: nil)
    }
}

public class AbstractGraph {
    public internal(set) var count = 0

    public init() {
        
    }
}
