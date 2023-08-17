//
//  NewsCell.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/13/23.
//

import Foundation
import UIKit

/// UITableViewCell of each news
class NewsCell: UITableViewCell {
    // title label of news article
    let titleLabel = UILabel()
    // Thumbnail image of news article
    let thumbNail = UIImageView()
    // container for title and thumbnail 
    let containerView = UIView()

    // MARK: Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// set up subviews
    func setupSubViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(thumbNail)

        let thumbnailHeight: CGFloat = 100
        let offset: CGFloat = 12
        // enable auto layout
        containerView.translatesAutoresizingMaskIntoConstraints = false
        thumbNail.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let thumbnailHeightConstraint = thumbNail.heightAnchor.constraint(equalToConstant: thumbnailHeight)
        thumbnailHeightConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            // set container view auto layout constraints
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: offset/2),
            containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: offset),
            containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -offset),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -offset/2),

            // set up thumbnail constraints
            thumbNail.widthAnchor.constraint(equalToConstant: thumbnailHeight*1.45),
            thumbnailHeightConstraint,
            thumbNail.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: offset),
            thumbNail.topAnchor.constraint(equalTo: containerView.topAnchor, constant: offset),
            thumbNail.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -offset),

            // set up title label constrains
            titleLabel.leftAnchor.constraint(equalTo: thumbNail.rightAnchor, constant: offset),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: offset),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -offset),
            titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -offset)
        ])
        // style container view
        containerView.backgroundColor = .containerBackground
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true

        // style thumbnail image view
        thumbNail.contentMode = .scaleAspectFill
        thumbNail.layer.cornerRadius = 15
        thumbNail.clipsToBounds = true
        thumbNail.accessibilityTraits = .image

        // style title 
        titleLabel.numberOfLines = 0
        titleLabel.accessibilityIdentifier = "news_cell_title"
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.accessibilityTraits = .staticText

    }
}
