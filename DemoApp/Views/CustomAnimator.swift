//
//  Animator.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/14/23.
//

import Foundation
import UIKit

/// Custom Animator while pushing/popping between NewsList screen and NewsDetails screen
/// this animation will mainly focus on animating the Thumbnail image in NewsCell(NewsList screen) to main news image in NewsDetails screen and vice versa, it will give users an experience that visually same image is moving from news list cell to news details screen
class CustomAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    /// indicates whether we are pushing or popping to navigation stack
    var isPresenting: Bool
    /// ImageView frame from news list cell
    var cellImageFrame: CGRect
    /// news cell that user tapped
    var cell: NewsCell
    /// shared Image  between two screens
    var image: UIImage
    /// property animator that animates images' frame and corner radius
    fileprivate var propertyAnimator: UIViewPropertyAnimator?

    /// Customer Animator Initializer
    /// - Parameters:
    ///   - isPresenting: indicate if we are moving from news list to news details or vice versa
    ///   - newsCell: news cell that tapped by user
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

    /// transition duration
    /// - Parameter transitionContext: context
    /// - Returns: TimeInterval for transition
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.20
    }

    /// interruptibleAnimator - animates shared image view between news list and news details screen
    /// - Parameter transitionContext: UIViewControllerContextTransitioning
    /// - Returns: UIViewImplicitlyAnimating
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        // check if we have already created property animator
        if let propertyAnimator = propertyAnimator {
            return propertyAnimator
        }

        // extract the container view when transitioning
        let container = transitionContext.containerView

        // extract from view controller and to view controller that transitioning from/to
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                fatalError()
        }
        // destination view controller's view
        guard let toView = toVC.view  else {
            fatalError()
        }

        // if presenting add  destination view controller's view to transitioning container
        if self.isPresenting {
            container.addSubview(toView)
        }

        // extract news detail view controller depending on push/pop behavior
        guard let newsDetailVC = self.isPresenting ? (toVC as? NewsDetailViewController) : (fromVC as? NewsDetailViewController) else {
            fatalError("checking for transition animation failed")
        }

        // prepare news detail screen sub views for animation
        newsDetailVC.articleImageView.alpha = 0
        newsDetailVC.articleTitleLabel.alpha = self.isPresenting ? 0 : 1
        newsDetailVC.articleSummary.alpha = self.isPresenting ? 0 : 1

        // original frame of the moving image
        let imageFrameInNewsDetails = newsDetailVC.articleImageView.superview!.convert(newsDetailVC.articleImageView.frame, to: nil)
        let movingImageFrame = self.isPresenting ? self.cellImageFrame : imageFrameInNewsDetails
        // this is the image view that animate between news list VC and news detail VC
        let movingImage = UIImageView(frame: movingImageFrame)
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

        // destination image frame in news details screen
        var destinationImageFrameInNewsDetail = newsDetailVC.articleImageView.superview!.convert(newsDetailVC.articleImageView.frame, to: nil)
        destinationImageFrameInNewsDetail.origin.y += labelHeight + 10 // stack view spacing
        destinationImageFrameInNewsDetail.origin.x += toView.layoutMargins.left // safe area
        // image frame width - extract the safe area margins from both side
        let width = toView.bounds.width - toView.layoutMargins.left  - toView.layoutMargins.right
        // image size calculation based on width and height ratio
        destinationImageFrameInNewsDetail.size = CGSize(width: width, height: toView.frame.width*0.65)

        // destination image frame based on push/pop
        let destinationImageFrame = self.isPresenting ? destinationImageFrameInNewsDetail : cellImageFrame

        // timing curve of animation
        let timing = TimingCurve(curve: .easeIn, dampingRatio: 0.8)
        // initialize UIViewPropertyAnimator
        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: timing)

        // add property animation
        animator.addAnimations {
            movingImage.frame = destinationImageFrame
            movingImage.layer.cornerRadius = self.isPresenting ? 0 : 15
            newsDetailVC.articleTitleLabel.alpha = self.isPresenting ? 1 : 0
            newsDetailVC.articleSummary.alpha = self.isPresenting ? 1 : 0
        }
        // animation completion block
        // need to hide moving image and since by the time original image in both screen will appear
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

    /// starts transitioning animation
    /// - Parameter transitionContext: UIViewControllerContextTransitioning
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
        // animate popping
        if !isPresenting {
            animatePop(using: transitionContext)
        }
    }

    ///  Popping animation
    /// - Parameter transitionContext: UIViewControllerContextTransitioning
    func animatePop(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        toVC.view.alpha = 0.4
        let fromVCFrame = transitionContext.initialFrame(for: fromVC)
        let popOffsetFrame = fromVCFrame.offsetBy(dx: fromVCFrame.width, dy: 55)

        transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                fromVC.view.frame = popOffsetFrame
                toVC.view.alpha = 1
        }, completion: {_ in
                transitionContext.completeTransition(true)
        })
    }
}

/// Timing curve with damping
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
