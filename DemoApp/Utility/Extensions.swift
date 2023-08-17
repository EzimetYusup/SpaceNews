//
//  UITableView+Extension.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/7/23.
//

import Foundation
import UIKit

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension UIColor {
    class var containerBackground: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ? UIColor.navyDark: UIColor.paleGrey
        }
    }

    class var paleGrey: UIColor {
        return UIColor(red: 243.0 / 255.0, green: 246.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
    }

    class var navyDark: UIColor {
        return UIColor(red: 5.0 / 255.0, green: 38.0 / 255.0, blue: 55.0 / 255.0, alpha: 1.0)
    }
}


// swiftlint:disable identifier_name
extension Array where Element: Hashable {
    static func - (a: Self, b: Self) -> Self {
        let set = Set(b)
        return a.filter { !set.contains($0) }
    }
}
