//
//  TreeNode.swift
//  
//
//  Created by Georg Tuparev on 01/03/2020.
//  Copyright © 2020 Tuparev Technologies. All rights reserved.
//

import Foundation

public class TreeNode: Node<Any>  {

    weak var parent: TreeNode?
    var children = [TreeNode]()

    var isRoot: Bool { parent == nil }
    var isLeaf: Bool { children.isEmpty }
    var hasChildren: Bool { !isLeaf }

    func root() -> TreeNode {
        if isRoot { return self }
        else      { return parent!.root() }
    }
}
