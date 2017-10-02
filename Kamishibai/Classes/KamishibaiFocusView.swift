//
//  KamishibaiFocusView.swift
//  Hello
//
//  Created by Keisuke Matsuo on 2017/08/12.
//
//

import UIKit

public class KamishibaiFocusView: UIView {

    // MARK: Properties
    public var focus: FocusType?
    public var animationDuration: TimeInterval = 0.5
    var maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillRule = kCAFillRuleEvenOdd
        layer.fillColor = UIColor.black.cgColor
        return layer
    }()

    // MARK: Initializing
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        maskLayer.frame = self.bounds
    }

    func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.55)
        layer.mask = maskLayer
        isUserInteractionEnabled = false
    }

    // MARK: Public Methods
    public func appear(focus: FocusType, completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        layer.add(alphaAnimation(animationDuration, from: 0.0, to: 1.0), forKey: nil)
        maskLayer.add(appearAnimation(animationDuration, focus: focus), forKey: nil)
        self.focus = focus

        CATransaction.commit()
    }

    public func move(to focus: FocusType, completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        maskLayer.add(moveAnimation(animationDuration, focus: focus), forKey: nil)
        self.focus = focus

        CATransaction.commit()
    }

    public func disappear(completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        layer.add(alphaAnimation(animationDuration, to: 0.0), forKey: nil)
        self.focus = nil

        CATransaction.commit()
    }

    // MARK: Private Methods

    // MARK: CAAnimation
    func maskPath(_ path: UIBezierPath) -> UIBezierPath {
        let screenRect = UIScreen.main.bounds
        return [path].reduce(UIBezierPath(rect: screenRect)) {
            $0.append($1)
            return $0
        }
    }

    func appearAnimation(_ duration: TimeInterval, focus: FocusType) -> CAAnimation {
        let beginPath = maskPath(focus.initialPath != nil ? focus.initialPath! : focus.path)
        let endPath = maskPath(focus.path)
        return pathAnimation(duration, beginPath: beginPath, endPath: endPath)
    }

    func disappearAnimation(_ duration: TimeInterval) -> CAAnimation {
        return alphaAnimation(duration, from: 1.0, to: 0.0)
    }

    func moveAnimation(_ duration: TimeInterval, focus: FocusType) -> CAAnimation {
        let endPath = maskPath(focus.path)
        return pathAnimation(duration, beginPath: nil, endPath: endPath)
    }

    func alphaAnimation(_ duration: TimeInterval, from: CGFloat? = nil, to: CGFloat) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.66, 0, 0.33, 1)
        if let from = from {
            animation.fromValue = from
        }
        animation.toValue = to
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        return animation
    }

    func pathAnimation(_ duration: TimeInterval, beginPath: UIBezierPath?, endPath: UIBezierPath) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.66, 0, 0.33, 1)
        if let path = beginPath {
            animation.fromValue = path.cgPath
        }
        animation.toValue = endPath.cgPath
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        return animation
    }
}

public protocol FocusType {
    var frame: CGRect { get }
    var initialPath: UIBezierPath? { get }
    var path: UIBezierPath { get }
}

public struct Focus {
    public struct Rect: FocusType {
        public var frame: CGRect
        public var initialFrame: CGRect?
        public var initialPath: UIBezierPath? {
            if let initialFrame = initialFrame {
                return UIBezierPath(rect: initialFrame)
            }
            return nil
        }
        public var path: UIBezierPath {
            return UIBezierPath(rect: frame)
        }
        public init(frame: CGRect, initialFrame: CGRect? = nil) {
            self.frame = frame
            self.initialFrame = initialFrame
        }
    }
    public struct RoundRect: FocusType {
        public var frame: CGRect
        public var initialFrame: CGRect?
        public var cornerRadius: CGFloat
        public var initialPath: UIBezierPath? {
            if let initialFrame = initialFrame {
                return UIBezierPath(roundedRect: initialFrame, cornerRadius: cornerRadius)
            }
            return nil
        }
        public var path: UIBezierPath {
            return UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius)
        }
        public init(frame: CGRect, initialFrame: CGRect? = nil, cornerRadius: CGFloat) {
            self.frame = frame
            self.initialFrame = initialFrame
            self.cornerRadius = cornerRadius
        }
    }
    public struct Oval: FocusType {
        public var frame: CGRect
        public var initialFrame: CGRect?
        public var initialPath: UIBezierPath? {
            if let initialFrame = initialFrame {
                return UIBezierPath(ovalIn: initialFrame)
            }
            return nil
        }
        public var path: UIBezierPath {
            return UIBezierPath(ovalIn: frame)
        }
        public init(frame: CGRect, initialFrame: CGRect? = nil) {
            self.frame = frame
            self.initialFrame = initialFrame
        }
    }
}
