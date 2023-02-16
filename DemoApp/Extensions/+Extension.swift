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
    static var containerBackground: UIColor {
           if #available(iOS 13.0, *) {
               return UIColor { (traits) -> UIColor in
                   // Return one of two colors depending on light or dark mode
                   return traits.userInterfaceStyle == .dark ? UIColor.navyDark: UIColor.paleGrey
               }
           } else {
               // Same old color used for iOS 12 and earlier
            return UIColor.paleGrey
           }
    }

    @nonobjc class var paleGrey: UIColor {
        return UIColor(red: 243.0 / 255.0, green: 246.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var navyDark: UIColor {
        return UIColor(red: 5.0 / 255.0, green: 38.0 / 255.0, blue: 55.0 / 255.0, alpha: 1.0)
    }
}

public enum TestingHelper {
    static var articleTitleLabelIdentifier = "articleTitleLabel"
    static var articleSummaryLabelIdentifier = "articleSummaryLabel"
}
