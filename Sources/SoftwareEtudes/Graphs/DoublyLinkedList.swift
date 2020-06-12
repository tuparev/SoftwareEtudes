//
//  DoublyLinkedList.swift
//  
//
//  Created by Georg Tuparev on 08/06/2020.
//

import Foundation

//MARK: - The Node -
public protocol DoublyLinkedProtocol: NodeProtocol {
    var next: Self? { get }
    var previous: Self? { get }
}

final public class DoublyLinkedNode<T>: Node<T>, DoublyLinkedProtocol where T: Equatable {
    public internal(set)      var next: DoublyLinkedNode?
    public internal(set) weak var previous: DoublyLinkedNode?

}


//MARK: - The List -
public protocol LinkedListProtocol {

    associatedtype AnyType: Equatable

    var head: DoublyLinkedNode<AnyType>? { get }
    var tail: DoublyLinkedNode<AnyType>? { get }

    func append(_ newNode: DoublyLinkedNode<AnyType>)
    //    mutating func insert(_ newNode: Node, after nodeWithTag: String)
    //    mutating func delete(_ node: Node)
    //    func showAllInReverse()
    //    subscript(tag: String) -> Node? { get }
}

public class DoublyLinkedList<T>: AbstractGraph, LinkedListProtocol where T: Equatable {
    public typealias AnyType = T

    public internal(set) var head: DoublyLinkedNode<AnyType>?
    public internal(set) var tail: DoublyLinkedNode<AnyType>?

    //MARK: - Basic operations -
    public func append(_ newNode: DoublyLinkedNode<AnyType>) {
        if let tailNode = tail {
            tailNode.next = newNode
            newNode.previous = tailNode
        }
        else { head = newNode }

        tail = newNode
        self.count += 1
    }

    public func insert(_ newNode: DoublyLinkedNode<AnyType>, after node:DoublyLinkedNode<AnyType>) {
        //TODO: Implement me!
    }

    public func insert(_ newNode: DoublyLinkedNode<AnyType>, before node:DoublyLinkedNode<AnyType>) {
        //TODO: Implement me!
    }

    public func remove(_ node: DoublyLinkedNode<AnyType>) {
        if (node.previous == nil) && (node.next == nil) { // The only node in the list
            head = nil
            tail = nil
        }
        else if head?.previous == nil {                    // Remove the head
            head = node.next
            head?.previous = nil
        }
        else if node.next == nil {                         // Remove tail
            tail = node.previous
            tail?.next = nil
        }
        else {                                            // Node in the middle
            node.next?.previous = node.previous
            node.previous?.next = node.next
        }
        node.previous = nil
        node.next = nil
    }

    public func removeAll() {
        var aNode = head

        while aNode != nil {
            head = aNode?.next
            aNode?.next = nil
            aNode = head
        }
    }
}
