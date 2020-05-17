//
//  MultiPathTreeNode.swift
//  
//
//  Created by Georg Tuparev on 17/05/2020.
//

import Foundation

public class MultiPathTreeNode: Node<Any>  {

    var alternatives = [AlternativeBrance]()
    
    public struct AlternativeBrance {
        var identifier: String
        var children = [MultiPathTreeNode]()
    }
}
