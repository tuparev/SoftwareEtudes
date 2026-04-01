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

public extension Array {

    /// Removes and returns elements at the specified positions.
    ///
    /// All elements following the removed positions are moved up to close the gap. Indices are
    /// processed in descending order so earlier indices remain valid after each removal.
    ///
    ///     var measurements = [1, 2, 3, 4, 5, 6, 7, 8]
    ///     let removed = measurements.removeElements(at: [1, 3, 5])
    ///     print(measurements)
    ///     // Prints "[1, 3, 5, 7, 8]"
    ///     print(removed)
    ///     // Prints "[6, 4, 2]"  (highest index first)
    ///
    /// - Parameter indicesToRemove: The positions of the elements to remove. Out-of-bounds indices
    ///   are silently ignored. Duplicate indices are treated as a single removal.
    /// - Returns: The removed elements ordered from the highest index to the lowest.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the array.
    @discardableResult
    @inlinable mutating func removeElements(at indicesToRemove: [Int]) -> [Element] {
        var result = [Element]()
        var seen   = Set<Int>()

        for indexToRemove in indicesToRemove.sorted(by: >) {
            guard indexToRemove >= 0, indexToRemove < count, seen.insert(indexToRemove).inserted else { continue }
            result.append(remove(at: indexToRemove))
        }

        return result
    }
}
