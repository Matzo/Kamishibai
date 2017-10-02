//
//  KamishibaiScene.swift
//  Pods
//
//  Created by Keisuke Matsuo on 2017/08/12.
//
//

import Foundation

public typealias KamishibaiSceneBlock = ((KamishibaiScene) -> Void)
public class KamishibaiScene: NSObject {

    // MARK: Properties
    public weak var kamishibai: Kamishibai?
    public var identifier: KamishibaiSceneIdentifierType?
    public var transition: KamishibaiTransitioningType?
    public var sceneBlock: KamishibaiSceneBlock

    var fulfillGestures: [UIGestureRecognizer] = []
    var isFinished: Bool = false
    var tapInRect: CGRect?

    // MARK: Initialization
    public init(id: KamishibaiSceneIdentifierType? = nil,
                transition: KamishibaiTransitioningType? = nil,
                scene: @escaping KamishibaiSceneBlock) {
        self.identifier = id
        self.transition = transition
        self.sceneBlock = scene
    }

    // MARK: Public Methods
    public func fulfill() {
        kamishibai?.fulfill(scene: self)
        disposeGestures()
    }
    public func fulfillWhenTap(view: UIView, inRect: CGRect? = nil) {
        // addTapGesture to view
        let tap = UITapGestureRecognizer(target: self, action: #selector(KamishibaiScene.didTapFulfill(gesture:)))
        view.addGestureRecognizer(tap)
        self.fulfillGestures.append(tap)
        tapInRect = inRect
    }
    public func fulfillWhenTapFocus() {
        guard let kamishibai = kamishibai else { return }
        guard let focus = kamishibai.focus.focusView.focus else { return }
        fulfillWhenTap(view: kamishibai.focus.view, inRect: focus.frame)
    }

    // MARK: Private Methods
    func disposeGestures() {
        fulfillGestures.forEach { (gesture) in
            gesture.view?.removeGestureRecognizer(gesture)
        }
        fulfillGestures.removeAll()
    }

    @objc func didTapFulfill(gesture: UITapGestureRecognizer) {
        if let inRect = tapInRect, let view = gesture.view {
            let point = gesture.location(in: view)
            if inRect.contains(point) {
                fulfill()
            }
        } else {
            fulfill()
        }
    }
}

public func == (l: KamishibaiScene, r: KamishibaiScene) -> Bool {
    if l === r {
        return true
    }
    guard let lId = l.identifier, let rId = r.identifier else { return false }
    return lId == rId
}
