//
//  Array+Additions.swift
//
//
//  Created by Georg Tuparev on 15/05/2024.
//  Copyright © See Framework's LICENSE file
//
//  Thanks for contributions, suggestions, ideas by:
//      1. Zhanna Hakobyan - see CONTRIBUTORS
//

import Foundation

public extension Array {

    /// Removes and returns elements at the specified positions.
    ///
    /// All the elements following the specified positions are moved up to close the gap.
    ///
    ///     var measurements = [1, 2, 3, 4, 5, 6, 7, 8]
    ///     let removed = measurements.removeElements(at: [1,3,5])
    ///     print(measurements)
    ///     // Prints "[1, 3, 5, 7, 8]"
    ///
    /// - Parameter indicesToRemove: The position of the elements to remove. If `indicesToRemove` are out of bounds, they are ignored
    /// - Returns: The elements at the specified indices.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the array.
    @discardableResult
    @inlinable mutating func removeElements(at indicesToRemove: [Int]) -> [Element] {
        var result = [Element]()

        for indexToRemove in indicesToRemove.sorted(by: >) {
            if count > indexToRemove {
                let removed = remove(at: indexToRemove)

                result.append(removed)
            }
        }

        return result
    }

}
