//
//  StatsView.swift
//  pInspire
//
//  Created by 臧晓雪 on 5/8/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit

// @IBDesignable
class StatsView: UIView {

    
    @IBInspectable
    var ratio: Float = 0.4 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable
    var chosen: Bool = false { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    @IBInspectable
    var clicked: Bool = false { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    @IBInspectable
    var context: String = "" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureLabel(TopLabel)
        TopLabel.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        //TopLabel.frame.origin = bounds.origin.offsetBy(dx: 0, dy: LabelOffset)
    }
    private lazy var TopLabel = createLabel()
    
    private func createLabel() -> UILabel {
        let label = UILabel()
        addSubview(label)
        label.numberOfLines = 0
        return label
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
    private func configureLabel(_ label: UILabel) {
        // label.text = "\(context)(\(ratio*100)%)"
        label.attributedText = centeredAttributedString("\(context)(\(ratio*100)%)", fontSize: fontSize)
        label.frame.size = CGSize.zero // (width: 0, height: bounds.height/2)
        label.bounds = bounds
    
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        label.sizeToFit()
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        // this next line makes our font obey the size slider in Setting app
        // however, we need to do one more thing to be more immediately "responsive" to this slider
        // we'll do that on Monday
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.font:font,.paragraphStyle:paragraphStyle])
    }
    
    private var fontSize: CGFloat {
        return bounds.size.height * SizeRatio.fontSizeToBoundsHeight
        //return min(bounds.width / CGFloat(context.count), bounds.size.height * SizeRatio.fontSizeToBoundsHeight)
    }
    private struct SizeRatio {
        static let fontSizeToBoundsHeight: CGFloat = 0.3
        static let cornerRadiusToBoundsHeight: CGFloat = 0.15
        static let barSizeToBoundswidth: CGFloat = 0.80
        // static let cornerOffsetToCornerRadius: CGFloat = 0.9
    }
    
    private struct Constants {
        static let rectBackgroundColor: UIColor = UIColor(cgColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        static let innerRectBackgroundColor: UIColor = UIColor(cgColor: #colorLiteral(red: 0.9568627451, green: 0.4078431373, blue: 0.2235294118, alpha: 1))
        // static let innerRectClickedBackgroundColor: UIColor = UIColor(cgColor: #colorLiteral(red: 0.9568627451, green: 0.4078431373, blue: 0.2235294118, alpha: 1))
        static let choiceStrokeColor: UIColor = UIColor(cgColor: #colorLiteral(red: 0.9215686275, green: 0.1882352941, blue: 0.2941176471, alpha: 1))
        static let chosenChoiceStrokeColor: UIColor = UIColor(cgColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))
        static let strokeWidth: CGFloat = 5.0
    }
    
    private var rectStrokeColor: UIColor {
        return clicked ? Constants.chosenChoiceStrokeColor : Constants.choiceStrokeColor
    }
    
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        Constants.rectBackgroundColor.setFill()
        roundedRect.fill()
        
        let innerRoundedRect = UIBezierPath(roundedRect: CGRect(origin: bounds.origin, size: CGSize(width: bounds.width * CGFloat(ratio), height: bounds.height)), cornerRadius: cornerRadius)
        
        Constants.innerRectBackgroundColor.setFill()
        innerRoundedRect.fill()
        
        rectStrokeColor.setStroke()
        roundedRect.lineWidth = Constants.strokeWidth
        roundedRect.stroke()
    }
 

}
