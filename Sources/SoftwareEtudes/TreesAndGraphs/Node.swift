//
//  Node.swift
//  
//
//  Created by Georg Tuparev on 29/02/2020.
//  Copyright © 2020 Tuparev Technologies. All rights reserved.
//

import Foundation

/// `Node` is an abstract class that has an `Element` and implement `Hashable` and `CustomStringConvertible` protocols.
/// All Tree and Graph nodes inherit from Node. They should add the functionality to connect nodes in different ways.
public class Node<Element: CustomStringConvertible>: CustomStringConvertible {

    public var description: String { ": \(element.description)" }
    public var element: Element

    init(_ element: Element) {
        self.element = element
    }
}

extension Node: Hashable {
    public static func == (lhs: Node<Element>, rhs: Node<Element>) -> Bool { lhs === rhs }

    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
}
