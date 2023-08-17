//
//  Loadable.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 8/13/23.
//

import Foundation
import UIKit

/// Loading State Containable Protocol
protocol LoadingStateContainable {
    /// Container for indicating different states like loading, failed
    var stateContainerView: UIView { get set }
    /// adds state container to view controller
    func addStateContainer(insets: UIEdgeInsets)
}

/// extension for LoadingStateContainable to add default addStateContainer implementation
extension LoadingStateContainable where Self: UIViewController {
    func addStateContainer(insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
        stateContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stateContainerView)
        NSLayoutConstraint.activate([
            stateContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            stateContainerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stateContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stateContainerView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        stateContainerView.backgroundColor = .containerBackground
        stateContainerView.isHidden = true
    }
}

/// Loadable Protocol to show loading state
protocol Loadable: LoadingStateContainable {

    /// loading indicator
    var loader: UIActivityIndicatorView { get set }

    /// shows loader
    func showLoader()

    /// Hides loader
    func hideLoader()
}

/// Default implementation of show loader and hide loader functions
extension Loadable where Self: UIViewController {
    func showLoader() {
        stateContainerView.isHidden = false
        stateContainerView.addSubview(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: stateContainerView.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: stateContainerView.centerYAnchor)
        ])
        loader.startAnimating()
        view.bringSubviewToFront(stateContainerView)
    }

    func hideLoader() {
        loader.stopAnimating()
        loader.removeFromSuperview()
        stateContainerView.isHidden = true
    }
}

/// Retriable protocol - for retrying after failure
@objc protocol Retriable: AnyObject {
    /// retry function
    func didPressRetry()
}

/// Failable protocol - for showing error state
protocol Failable: LoadingStateContainable {

    /// Shows error screen with error message
    /// - Parameter errorMessage: String
    func showErrorStateView(_ errorMessage: String)

    /// Hides error state view
    func hideErrorStateView()
}

/// default implementation of Failable protocol for UIViewController and Retriable
extension Failable where Self: UIViewController & Retriable {

    /// Default implementation of show error state view
    /// will display warning icon, error message and retry button in vertical stack view
    /// retry button is linked to Retriable's didPressRetry()
    /// - Parameter errorMessage: String
    func showErrorStateView(_ errorMessage: String) {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .equalSpacing

        let warningImage = UIImage(systemName: "exclamationmark.triangle")
        let warningImageView = UIImageView(image: warningImage)
        warningImageView.contentMode = .scaleAspectFit

        let messageLabel = UILabel()
        messageLabel.text = errorMessage
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        let retryButton = UIButton(type: .system)
        retryButton.setTitle("Retry", for: .normal)
        retryButton.addTarget(self, action: #selector(didPressRetry), for: .touchUpInside)

        stackView.addArrangedSubview(warningImageView)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(retryButton)

        stateContainerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: stateContainerView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: stateContainerView.trailingAnchor, constant: -10),
            stackView.centerXAnchor.constraint(equalTo: stateContainerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: stateContainerView.centerYAnchor)
        ])
        stateContainerView.isHidden = false
        view.bringSubviewToFront(stateContainerView)
    }

    func hideErrorStateView() {
        stateContainerView.subviews.forEach {$0.removeFromSuperview()}
    }
}
