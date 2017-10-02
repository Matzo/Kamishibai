//
//  KamishibaiTransitioning.swift
//  Pods
//
//  Created by Keisuke Matsuo on 2017/08/12.
//
//

import Foundation

public typealias NextViewController = UIViewController
public typealias FulfillTransitioning = ((NextViewController) -> Void)
public enum KamishibaiTransitioningType {
    case push(UIViewController)
    case pop
    case popToRoot
    case present(UIViewController)
    case dismiss
    case custom((FulfillTransitioning) -> Void)
}

public class KamishibaiTransitioning: NSObject {
    weak var originalNavigationDelegate: UINavigationControllerDelegate?
    var fulfill: FulfillTransitioning?

    // MARK: Public Methods
    public func transision(fromVC: UIViewController, type: KamishibaiTransitioningType, animated: Bool, completion: @escaping (NextViewController) -> Void) {
        switch type {
        case .push(let toVC):
            push(fromVC: fromVC, toVC: toVC, animated: animated, fulfill: completion)
        case .pop:
            pop(fromVC: fromVC, animated: animated, fulfill: completion)
        case .popToRoot:
            popToRoot(fromVC: fromVC, animated: animated, fulfill: completion)
        case .present(let toVC):
            present(viewController: toVC, fromVC: fromVC, animated: animated, fulfill: completion)
        case .dismiss:
            dismiss(fromVC: fromVC, animated: animated, fulfill: completion)
        case .custom(let fulfill):
            fulfill(completion)
        }
    }

    // MARK: Private Methods
    func push(fromVC: UIViewController, toVC: UIViewController, animated: Bool,
              fulfill: @escaping FulfillTransitioning) {
        guard let navi = fromVC as? UINavigationController ?? fromVC.navigationController else {
            fulfill(fromVC)
            return
        }
        self.fulfill = fulfill
        prepareDelegate(fromVC: fromVC)
        navi.pushViewController(toVC, animated: animated)
    }

    func pop(fromVC: UIViewController, animated: Bool, fulfill: @escaping FulfillTransitioning) {
        guard let navi = fromVC as? UINavigationController ?? fromVC.navigationController else {
            fulfill(fromVC)
            return
        }
        self.fulfill = fulfill
        prepareDelegate(fromVC: fromVC)
        navi.popViewController(animated: animated)
    }

    func popToRoot(fromVC: UIViewController, animated: Bool, fulfill: @escaping FulfillTransitioning) {
        guard let navi = fromVC as? UINavigationController ?? fromVC.navigationController else {
            fulfill(fromVC)
            return
        }
        self.fulfill = fulfill
        prepareDelegate(fromVC: fromVC)
        navi.popToRootViewController(animated: animated)
    }

    func prepareDelegate(fromVC: UIViewController) {
        if let originalDelegate = fromVC.navigationController?.delegate {
            originalNavigationDelegate = originalDelegate
        }
        fromVC.navigationController?.delegate = self
    }

    func present(viewController: UIViewController, fromVC: UIViewController, animated: Bool, fulfill: @escaping FulfillTransitioning) {
        fromVC.present(viewController, animated: animated) {
            fulfill(viewController)
        }
    }

    func dismiss(fromVC: UIViewController, animated: Bool, fulfill: @escaping FulfillTransitioning) {
        let parent = frontViewController(fromVC)
        fromVC.dismiss(animated: animated) {
            fulfill(parent)
        }
    }

    func frontViewController(_ vc: UIViewController) -> UIViewController {
        guard let presentingVC = vc.presentingViewController else { return vc }
        if let navi = presentingVC as? UINavigationController {
            return navi.topViewController ?? vc
        }
        if let tab = presentingVC as? UITabBarController, let vcs = tab.viewControllers {
            return vcs[tab.selectedIndex]
        }
        return presentingVC
    }
}

extension KamishibaiTransitioning: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        originalNavigationDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let originalDelegate = originalNavigationDelegate {
            navigationController.delegate = originalDelegate
            originalDelegate.navigationController?(navigationController, didShow: viewController, animated: animated)
        }
        resetNavigationDelegate(navigationController)

        if let fulfill = self.fulfill, let topVC = navigationController.topViewController {
            fulfill(topVC)
        }
    }

    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return originalNavigationDelegate?.navigationControllerSupportedInterfaceOrientations?(navigationController)
            ?? UIApplication.shared.keyWindow?.rootViewController?.supportedInterfaceOrientations
            ?? .all
    }

    public func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return originalNavigationDelegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController)
        ?? UIApplication.shared.keyWindow?.rootViewController?.preferredInterfaceOrientationForPresentation
        ?? .unknown
    }

    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return originalNavigationDelegate?.navigationController?(navigationController, interactionControllerFor:animationController)
    }

    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return originalNavigationDelegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }

    func resetNavigationDelegate(_ navigationController: UINavigationController) {
        navigationController.delegate = originalNavigationDelegate
        originalNavigationDelegate = nil
    }
}

