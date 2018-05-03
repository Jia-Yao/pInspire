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
        // Initialization code
    }

    @IBOutlet weak var voteAnonymouslySwitch: UISwitch!
    @IBOutlet weak var articlesButtonView: UIButton!
    @IBOutlet weak var initiatorLabelView: UILabel!
    @IBOutlet weak var questionLabelView: UILabel!
    @IBOutlet var choiceButtonView: [UIButton]! 
    @IBOutlet weak var questionLableView: UILabel!
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
