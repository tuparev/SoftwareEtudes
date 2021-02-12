//
//  Tree.swift
//  
//
//  Created by Georg Tuparev on 17/06/2020.
//

import Foundation

//MARK: - The Node -
public protocol TreeNodeProtocol: NodeProtocol {
    var parent: Self? { get }
    var children: [Self]? { get }
}

final public class TreeNode<T>: Node<T>, TreeNodeProtocol where T: Equatable {
    public internal(set) weak var parent: TreeNode?
    public internal(set)      var children: [TreeNode]?
}


//MARK: - Tree -
public protocol TreeProtocol {

    associatedtype AnyType: Equatable

    var root: TreeNode<AnyType>? { get }

    func addChild(_ newNode: TreeNode<AnyType>)
}


public class Tree<T>: AbstractGraph, TreeProtocol where T: Equatable {
    public typealias AnyType = T

    public internal(set) var root: TreeNode<AnyType>?

    //MARK: - Basic operations -
    public func addChild(_ newNode: TreeNode<AnyType>) {
        //TODO: Implement me!
    }

}
