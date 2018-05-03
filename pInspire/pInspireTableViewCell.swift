//
//  pInspireTableViewCell.swift
//  pInspire
//
//  Created by 臧晓雪 on 4/29/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit

protocol pInspireTableViewCellDelegate : class {
    func didTapChoice(_ sender: pInspireTableViewCell, button: UIButton)
    // func didTapStats(_ sender: pInspireTableViewCell)
}

class pInspireTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
    }
    
    @IBOutlet weak var voteAnonymouslySwitch: UISwitch!
    
    @IBOutlet weak var articlesButtonView: UIButton!

    @IBOutlet weak var initiatorLabelView: UILabel!
    
    @IBOutlet weak var questionLabelView: UILabel!
    
    
    @IBOutlet var choiceButtonView: [UIButton]! {
        didSet {
            // Button UI
            for button in self.choiceButtonView {
                // button.layer.borderWidth = 1.0
                button.layer.cornerRadius = 8
                // button.layer.borderColor = UIColor.blue.cgColor
                // button.layer.backgroundColor = #colorLiteral(red: 1, green: 0.5980699052, blue: 0.1727632673, alpha: 1)
                // button.layer.masksToBounds = true
            }
        }
    }
    
    @IBOutlet weak var questionLableView: UILabel! {
        didSet {
            questionLableView.layer.borderWidth = 1.0
            questionLableView.layer.cornerRadius = 8
            questionLabelView.layer.borderColor = UIColor.blue.cgColor

            questionLableView.backgroundColor = UIColor.white
            questionLableView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var reportButtonView: UIButton!
    @IBOutlet weak var statsButtonView: UIButton!
    @IBOutlet weak var voteLabelView: UILabel!
    
    var voteAnonymously: Bool {
        get {
            return voteAnonymouslySwitch.isOn
        }
    }
    
    weak var delegate: pInspireTableViewCellDelegate?
    
    @IBAction func tapChoice(_ sender: UIButton) {
        delegate?.didTapChoice(self, button: sender)
    }
    
    @IBAction func tapReport(_ sender: UIButton) {
        // delegate?.didTapReport(self, button: sender)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
