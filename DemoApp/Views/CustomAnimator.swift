//
//  Animator.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/14/23.
//

import Foundation
import UIKit

class CustomAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    var isPresenting: Bool
    var cellImageFrame: CGRect
    var cell: NewsCell
    var image: UIImage

    fileprivate var propertyAnimator: UIViewPropertyAnimator?

    init(isPresenting: Bool, newsCell: NewsCell) {
        self.isPresenting = isPresenting
        self.cell = newsCell
        let imageFrame = cell.thumbNail.superview!.convert(cell.thumbNail.frame, to: nil)
        self.cellImageFrame = imageFrame
        if let image = newsCell.thumbNail.image {
            self.image = image
        } else {
            self.image = UIImage(systemName: "photo")!
        }
    }

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.20
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let propertyAnimator = propertyAnimator {
            return propertyAnimator
        }

        let container = transitionContext.containerView

        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                fatalError()
        }

        guard let toView = toVC.view  else {
            fatalError()
        }

        if self.isPresenting {
            container.addSubview(toView)
        }

        guard let newsDetailVC = self.isPresenting ? (toVC as? NewsDetailViewController) : (fromVC as? NewsDetailViewController) else {
            fatalError("checking for transition animation failed")
        }

        // prepare news detail screen views for animation
        newsDetailVC.articleImageView.alpha = 0
        newsDetailVC.articleTitleLabel.alpha = self.isPresenting ? 0 : 1
        newsDetailVC.articleSummary.alpha = self.isPresenting ? 0 : 1

        // frame origin of the moving image
        let imageFrameInNewsDetails = newsDetailVC.articleImageView.superview!.convert(newsDetailVC.articleImageView.frame, to: nil)
        let movingImageOrigin = self.isPresenting ? self.cellImageFrame : imageFrameInNewsDetails
        // this is the image view that animate between news list VC and news detail VC
        let movingImage = UIImageView(frame: movingImageOrigin)
        movingImage.contentMode = .scaleAspectFill
        movingImage.layer.cornerRadius = 15
        movingImage.clipsToBounds = true
        movingImage.image = self.image

        // add animated image to container view
        container.addSubview(movingImage)

        self.cell.thumbNail.alpha = self.isPresenting ? 1:0

        // calculate hight of the title label, so we can determine the image view's destination Y coordinate
        let titleLabel = newsDetailVC.articleTitleLabel
        newsDetailVC.articleTitleLabel.sizeToFit()

        let labelWidth = toView.bounds.width - toView.layoutMargins.left  - toView.layoutMargins.right
        let maxLabelSize = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        let actualLabelSize = titleLabel.text!.boundingRect(with: maxLabelSize, options: [.usesLineFragmentOrigin], attributes: [.font: titleLabel.font!], context: nil)
        let labelHeight = actualLabelSize.height

        var destinationImageFrameInNewsDetail = newsDetailVC.articleImageView.superview!.convert(newsDetailVC.articleImageView.frame, to: nil)
        destinationImageFrameInNewsDetail.origin.y += labelHeight + 10 // stack view spacing
        destinationImageFrameInNewsDetail.origin.x += toView.layoutMargins.left // safe area

        let width = toView.bounds.width - toView.layoutMargins.left  - toView.layoutMargins.right
        destinationImageFrameInNewsDetail.size = CGSize(width: width, height: toView.frame.width*0.65)

        let destinationImageFrame = self.isPresenting ? destinationImageFrameInNewsDetail : cellImageFrame

        let timing = TimingCurve(curve: .easeIn, dampingRatio: 0.8)
        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: timing)

        animator.addAnimations {
            movingImage.frame = destinationImageFrame
            movingImage.layer.cornerRadius = self.isPresenting ? 0 : 15
            newsDetailVC.articleTitleLabel.alpha = self.isPresenting ? 1 : 0
            newsDetailVC.articleSummary.alpha = self.isPresenting ? 1 : 0
        }

        animator.addCompletion { _ in
            newsDetailVC.articleImageView.alpha = self.isPresenting ? 1 : 0
            self.cell.thumbNail.alpha = self.isPresenting ? 0:1
            movingImage.removeFromSuperview()
            if !self.isPresenting {
                newsDetailVC.view.removeFromSuperview()
            }
            transitionContext.completeTransition(true)
            self.propertyAnimator = nil
        }
        propertyAnimator = animator
        return animator
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        animator.startAnimation()

        if !isPresenting {
            animatePop(using: transitionContext)
        }
    }

    func animatePop(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!

        let fromVCFrame = transitionContext.initialFrame(for: fromVC)
        let popOffsetFrame = fromVCFrame.offsetBy(dx: fromVCFrame.width, dy: 55)

        transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                fromVC.view.frame = popOffsetFrame
        }, completion: {_ in
                transitionContext.completeTransition(true)
        })
    }
}

@available(iOS 11.0, *)
public class TimingCurve: NSObject, UITimingCurveProvider {

    public let timingCurveType: UITimingCurveType

    public let cubicTimingParameters: UICubicTimingParameters?

    public let springTimingParameters: UISpringTimingParameters?

    public override init() {
        self.timingCurveType = .cubic
        self.cubicTimingParameters = UICubicTimingParameters(animationCurve: .easeInOut)
        self.springTimingParameters = nil

        super.init()
    }

    public init(cubic: UICubicTimingParameters, spring: UISpringTimingParameters? = nil) {
        if spring != nil {
            self.timingCurveType = .composed
        } else {
            self.timingCurveType = .cubic
        }
        self.cubicTimingParameters = cubic
        self.springTimingParameters = spring

        super.init()
    }

    public init(curve: UIView.AnimationCurve, dampingRatio: CGFloat, initialVelocity: CGVector? = nil) {
        self.timingCurveType = .composed
        self.cubicTimingParameters = UICubicTimingParameters(animationCurve: curve)

        if let velocity = initialVelocity {
            self.springTimingParameters = UISpringTimingParameters(dampingRatio: dampingRatio, initialVelocity: velocity)
        } else {
            self.springTimingParameters = UISpringTimingParameters(dampingRatio: dampingRatio)
        }

        super.init()
    }

    public init(curve: UIView.AnimationCurve, damping: CGFloat, initialVelocity: CGVector, mass: CGFloat, stiffness: CGFloat) {
        self.timingCurveType = .composed
        self.cubicTimingParameters = UICubicTimingParameters(animationCurve: curve)
        self.springTimingParameters = UISpringTimingParameters(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: initialVelocity)

        super.init()
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        return self
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.timingCurveType.rawValue, forKey: "timingCurveType")
    }

    public required init?(coder aDecoder: NSCoder) {
        self.timingCurveType = UITimingCurveType(rawValue: aDecoder.decodeObject(forKey: "timingCurveType") as? Int ?? 0) ?? .cubic
        self.cubicTimingParameters = UICubicTimingParameters(animationCurve: .easeInOut)
        self.springTimingParameters = nil
    }
}
