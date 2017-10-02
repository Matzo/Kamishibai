//
//  SampleGuideLabel.swift
//  Kamishibai
//
//  Created by Matsuo Keisuke on 9/18/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class SampleGuideLabel: UILabel {
    init(_ text: String) {
        super.init(frame: CGRect.zero)
        self.text = text
        self.numberOfLines = 0
        self.sizeToFit()
        self.textColor = UIColor.white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
