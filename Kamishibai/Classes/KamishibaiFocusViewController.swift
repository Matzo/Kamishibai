//
//  KamishibaiFocusViewController.swift
//  Hello
//
//  Created by Keisuke Matsuo on 2017/08/12.
//
//

import UIKit

public enum FocusAccesoryViewPosition {
    case topRight(CGPoint)
    case bottomRight(CGPoint)
    case center(CGPoint)
    case point(CGPoint)
}

public class KamishibaiFocusViewController: UIViewController {

    // MARK: Properties
    let focusView = KamishibaiFocusView(frame: CGRect.zero)
    var customViews = [UIView]()
    let transitioning = KamishibaiFocusTransitioning(state: .presenting)
    weak var kamishibai: Kamishibai?
    public var isFocusing: Bool {
        return self.view.superview != nil
    }

    // MARK: UIViewController Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    var first = true
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        focusView.frame = view.bounds
    }

    // MARK: Initializing
    func setupViews() {
        view.addSubview(focusView)
        view.backgroundColor = UIColor.clear
//        view.isUserInteractionEnabled = false
    }

    // MARK: Public Methods
    public func on(view: UIView? = nil, focus: FocusType, completion: (() -> Void)? = nil) {
        guard let targetView = view ?? kamishibai?.currentViewController?.view else { return }

        let focusBlock = {
            if let _ = self.focusView.focus {
                self.focusView.move(to: focus, completion: completion)
            } else {
                self.focusView.appear(focus: focus, completion: completion)
            }
        }

        if self.view.superview == nil {
            present(onView: targetView, completion: { 
                focusBlock()
            })
        } else {
            focusBlock()
        }
    }

    override public func dismiss(animated flag: Bool, completion: (() -> Swift.Void)? = nil) {
        hideAllCustomViews()
        let duration = isFocusing ? focusView.animationDuration : 0
        UIView.animate(withDuration: duration, delay: 0,
                       usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
            self.view.alpha = 0
        }) { (_) in
            self.view.alpha = 1
            self.view.removeFromSuperview()
            self.clean()
            completion?()
        }
    }

    public func addCustomView(view: UIView, position: FocusAccesoryViewPosition, completion: @escaping () -> Void = {}) {
        self.customViews.append(view)
        self.view.addSubview(view)
        view.sizeToFit()
        switch position {
        case .topRight(let adjust):
            view.frame.origin.x = self.view.bounds.size.width - view.frame.size.width + adjust.x
            if let focus = focusView.focus {
                view.frame.origin.y = focus.frame.minY - view.frame.size.height + adjust.y
            }
        case .bottomRight(let adjust):
            view.frame.origin.x = self.view.bounds.size.width - view.frame.size.width + adjust.x
            if let focus = focusView.focus {
                view.frame.origin.y = focus.frame.maxY + adjust.y
            }
        case .center(let adjust):
            if let focus = focusView.focus {
                view.center = CGPoint(x: focus.frame.midX + adjust.x, y: focus.frame.midY + adjust.y)
            } else {
                view.center = CGPoint(x: self.view.frame.midX + adjust.x, y: self.view.frame.midY + adjust.y)
            }
        case .point(let point):
            view.frame.origin = point
        }

        if let animate = view as? KamishibaiCustomViewAnimation {
            animate.show(animated: true, fulfill: completion)
        }
    }

    public func hideAllCustomViews() {
        customViews.forEach { (view) in
            if let animate = view as? KamishibaiCustomViewAnimation {
                animate.hide(animated: true, fulfill: {})
            }
        }
    }

    public func clean() {
        customViews.forEach { (view) in
            view.removeFromSuperview()
        }
        customViews.removeAll()
        focusView.disappear()
        focusView.maskLayer.path = nil
    }

    // MARK: Private Methods
    func present(onView view: UIView, completion: (() -> Void)? = nil) {
        focusView.focus = nil
        view.addSubview(self.view)
        completion?()
    }

    // MARK: Class Methods
    static func create() -> KamishibaiFocusViewController {
        let vc = KamishibaiFocusViewController()
        vc.transitioningDelegate = vc
        vc.modalPresentationStyle = .overCurrentContext
        return vc
    }
}

// MARK: - Transitioning
extension KamishibaiFocusViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitioning.state = .presenting
        return transitioning
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitioning.state = .dismissing
        return transitioning
    }
}

enum KamishibaiFocusTransitioningState {
    case presenting
    case dismissing
}

class KamishibaiFocusTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    var state: KamishibaiFocusTransitioningState

    init(state: KamishibaiFocusTransitioningState) {
        self.state = state
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        switch self.state {
        case .presenting: return 0.5
        case .dismissing: return 0.5
        }
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
        let duration = self.transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView

        switch self.state {
        case .presenting:
            containerView.addSubview(toVC.view)
            toVC.view.alpha = 0

            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                           options: [.beginFromCurrentState], animations:
                { () -> Void in
                    toVC.view.alpha = 1
            }, completion: { (done) -> Void in
                transitionContext.completeTransition(true)
            })

        case .dismissing:
            containerView.addSubview(fromVC.view)
            if fromVC.modalPresentationStyle != .overCurrentContext {
                containerView.insertSubview(toVC.view, at: 0)
            }

            fromVC.view.alpha = 1
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                           options: [.beginFromCurrentState], animations:
                { () -> Void in
                    fromVC.view.alpha = 0
            }, completion: { (done) -> Void in
                transitionContext.completeTransition(true)
            })

        }
    }
}
