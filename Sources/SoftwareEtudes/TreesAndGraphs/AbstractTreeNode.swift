//
//  AbstractTreeNode.swift
//  
//
//  Created by Georg Tuparev on 17/05/2020.
//

import Foundation

public class AbstractTreeNode: Node<Any>  {
    weak var parent: AbstractTreeNode?

    var isRoot: Bool { parent == nil }

    func root() -> AbstractTreeNode {
        if isRoot { return self }
        else      { return parent!.root() }
    }
}
