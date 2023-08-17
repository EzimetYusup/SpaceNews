//
//  Pages.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/7/23.
//

import Foundation

/// Pages - utility model for keeping track of total # pages, current page, total items
struct Pages<T: Equatable>: Equatable {
    /// holds all the items
    var values: [T] = []
    /// current page
    var currentPage: Int = 0
    /// total number pages
    var totalPages: Int = 1

    /// represents if we reached last page
    var isComplete: Bool {
        return currentPage >= totalPages
    }

    /// adds items of a page to total items, increments page by 1
    /// - Parameter values: items in single page to add
    mutating func addPage(values: [T]) {
        guard currentPage < totalPages else { return }
        self.currentPage += 1
        self.values.append(contentsOf: values)
    }
}
