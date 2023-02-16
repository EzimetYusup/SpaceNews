//
//  Pages.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/7/23.
//

import Foundation

struct Pages<T: Equatable>: Equatable {
    var values: [T] = []
    var currentPage: Int = 0
    var totalPages: Int = 1

    var isComplete: Bool {
        return currentPage >= totalPages
    }
    mutating func setTotlaPage(totalPages: Int) {
        self.totalPages = totalPages
    }
    mutating func addPage(values: [T]) {
        guard currentPage < totalPages else { return }
        self.currentPage += 1
        self.values.append(contentsOf: values)
    }
}
