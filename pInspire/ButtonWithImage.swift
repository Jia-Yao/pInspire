//
//  ButtonWithImage.swift
//  pInspire
//
//  Created by Jia Yao on 5/15/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit

class ButtonWithImage: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView?.isHidden == false {
            imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width - 55), bottom: 5, right: 5)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (imageView?.frame.width)!)
        } else {
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    override func setImage(_ image: UIImage?, for state: UIControlState) {
        super.setImage(image, for: state)
        layoutIfNeeded()
    }
}
