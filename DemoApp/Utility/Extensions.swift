//
//  UITableView+Extension.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/7/23.
//

import Foundation
import UIKit

/// UIColor extensions
extension UIColor {

    /// Container background color with dark mode support
    class var containerBackground: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ? UIColor.navyDark: UIColor.paleGrey
        }
    }

    /// container background color for light mode
    class var paleGrey: UIColor {
        return UIColor(red: 243.0 / 255.0, green: 246.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
    }

    /// container background color for dark mode
    class var navyDark: UIColor {
        return UIColor(red: 5.0 / 255.0, green: 38.0 / 255.0, blue: 55.0 / 255.0, alpha: 1.0)
    }
}

/// Array extension to find different elements between two arrays
extension Array where Element: Hashable {
    // swiftlint:disable identifier_name
    static func - (a: Self, b: Self) -> Self {
        let set = Set(b)
        return a.filter { !set.contains($0) }
    }
}

/// Sequence extension to remove duplicate elements
extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
