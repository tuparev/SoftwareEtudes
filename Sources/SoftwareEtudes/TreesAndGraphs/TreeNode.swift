//
//  TreeNode.swift
//  
//
//  Created by Georg Tuparev on 01/03/2020.
//  Copyright © 2020 Tuparev Technologies. All rights reserved.
//

import Foundation

public class TreeNode: AbstractTreeNode  {
    var children = [TreeNode]()

    var isLeaf: Bool { children.isEmpty }
    var hasChildren: Bool { !isLeaf }
}
