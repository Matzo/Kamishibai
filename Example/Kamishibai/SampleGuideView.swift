//
//  SampleGuideView.swift
//  Kamishibai
//
//  Created by Matsuo Keisuke on 8/13/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import Kamishibai

class SampleGuideView: UIView, KamishibaiCustomViewAnimation {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!

    func show(animated: Bool, fulfill: @escaping () -> Void) {
        alpha = 0
        transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
        }) { (_) in
            fulfill()
        }
    }
    func hide(animated: Bool, fulfill: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.0
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (_) in
            fulfill()
        }
    }

    static func create() -> SampleGuideView {
        let nib = UINib(nibName: String(describing: SampleGuideView.self), bundle: nil)
            .instantiate(withOwner: nil, options: nil)
        return nib.first as! SampleGuideView
    }
}
