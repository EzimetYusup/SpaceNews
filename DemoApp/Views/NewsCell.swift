//
//  NewsCell.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/13/23.
//

import Foundation
import TinyConstraints
import UIKit

/// UITableViewCell of each news
class NewsCell: UITableViewCell {
    // title label of news article
    let titleLabel = UILabel()
    // Thumbnail image of news article
    let thumbNail = UIImageView()
    // container for title and thumbnail 
    let containerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUp() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(thumbNail)

        let offset: CGFloat = 12
        containerView.topToSuperview(offset: offset/2)
        containerView.leftToSuperview(offset: offset)
        containerView.rightToSuperview(offset: -offset)
        containerView.bottomToSuperview(offset: -offset/2)
        containerView.backgroundColor = .containerBackground
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true

        let height: CGFloat = 100
        thumbNail.leftToSuperview(offset: offset)
        thumbNail.width(height*1.45)
        thumbNail.height(height, priority: .defaultHigh)
        thumbNail.topToSuperview(offset: offset)
        thumbNail.bottomToSuperview(offset: -offset)
        thumbNail.contentMode = .scaleAspectFill
        thumbNail.layer.cornerRadius = 15
        thumbNail.clipsToBounds = true

        titleLabel.topToSuperview(offset: offset)
        titleLabel.leftToRight(of: thumbNail, offset: offset)
        titleLabel.rightToSuperview(offset: -offset)
        titleLabel.bottomToSuperview(offset: -offset)
        titleLabel.numberOfLines = 0
        titleLabel.accessibilityIdentifier = "news_cell_title"
    }
}
