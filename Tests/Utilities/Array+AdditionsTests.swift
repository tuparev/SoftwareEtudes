//
//  Array+AdditionsTests.swift
//
//
//  Created by Georg Tuparev on 15/05/2024.
//  Copyright © See Framework's LICENSE file
//
//  Thanks for contributions, suggestions, ideas by:
//      1. Zhanna Hakobyan - see CONTRIBUTORS
//

import Testing
@testable import SoftwareEtudesUtilities

@Suite("Array+Additions")
struct ArrayAdditionsTests {

    // MARK: - Happy path

    @Suite("happy path")
    struct HappyPath {

        @Test("multiple valid indices removes correct elements")
        func removeElements_multipleValidIndices() {
            var sut = [1, 2, 3, 4, 5, 6, 7, 8]
            let removed = sut.removeElements(at: [1, 3, 5])
            #expect(sut == [1, 3, 5, 7, 8])
            #expect(removed.sorted(by: <) == [2, 4, 6])
        }

        @Test("single index removes one element")
        func removeElements_singleIndex() {
            var sut = ["a", "b", "c"]
            let removed = sut.removeElements(at: [1])
            #expect(sut == ["a", "c"])
            #expect(removed == ["b"])
        }

        @Test("all indices leaves empty array")
        func removeElements_allIndices() {
            var sut = [10, 20, 30]
            let removed = sut.removeElements(at: [0, 1, 2])
            #expect(sut.isEmpty)
            #expect(removed.sorted(by: <) == [10, 20, 30])
        }

        @Test("first and last index removes correctly")
        func removeElements_firstAndLastIndex() {
            var sut = [1, 2, 3, 4, 5]
            let removed = sut.removeElements(at: [0, 4])
            #expect(sut == [2, 3, 4])
            #expect(removed.sorted(by: <) == [1, 5])
        }
    }

    // MARK: - Edge cases

    @Suite("edge cases")
    struct EdgeCases {

        @Test("empty indices does not mutate array")
        func removeElements_emptyIndices() {
            var sut = [1, 2, 3]
            let removed = sut.removeElements(at: [])
            #expect(sut == [1, 2, 3])
            #expect(removed.isEmpty)
        }

        @Test("empty source array returns empty without crashing")
        func removeElements_emptyArray() {
            var sut = [Int]()
            let removed = sut.removeElements(at: [0, 1, 2])
            #expect(sut.isEmpty)
            #expect(removed.isEmpty)
        }

        @Test("out-of-bounds indices are ignored")
        func removeElements_outOfBoundsIndices() {
            var sut = [1, 2, 3]
            let removed = sut.removeElements(at: [5, 10, 100])
            #expect(sut == [1, 2, 3])
            #expect(removed.isEmpty)
        }

        @Test("negative index is ignored")
        func removeElements_negativeIndex() {
            var sut = [1, 2, 3]
            let removed = sut.removeElements(at: [-1])
            #expect(sut == [1, 2, 3])
            #expect(removed.isEmpty)
        }

        @Test("mixed valid and out-of-bounds indices removes only valid")
        func removeElements_mixedValidAndOutOfBoundsIndices() {
            var sut = [1, 2, 3, 4, 5]
            let removed = sut.removeElements(at: [1, 99, 3])
            #expect(sut == [1, 3, 5])
            #expect(removed.sorted(by: <) == [2, 4])
        }

        @Test("duplicate indices remove element only once")
        func removeElements_duplicateIndices() {
            var sut = [10, 20, 30, 40]
            let removed = sut.removeElements(at: [1, 1, 1])
            #expect(sut == [10, 30, 40])
            #expect(removed == [20])
        }
    }

    // MARK: - Generic element type

    @Suite("generic element type")
    struct GenericElementType {

        @Test("works with String arrays")
        func removeElements_stringArray() {
            var sut = ["apple", "banana", "cherry", "date"]
            let removed = sut.removeElements(at: [0, 2])
            #expect(sut == ["banana", "date"])
            #expect(removed.sorted() == ["apple", "cherry"])
        }
    }

    // MARK: - @discardableResult

    @Suite("discardableResult")
    struct DiscardableResult {

        @Test("result can be discarded without warning")
        func removeElements_discardableResult() {
            var sut = [1, 2, 3]
            sut.removeElements(at: [0])
            #expect(sut == [2, 3])
        }
    }
}
