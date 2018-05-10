//
//  roundedButtonView.swift
//  pInspire
//
//  Created by 臧晓雪 on 5/2/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit

import UIKit

@IBDesignable

class RoundButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 10{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
