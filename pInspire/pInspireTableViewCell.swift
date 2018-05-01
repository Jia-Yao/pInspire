//
//  pInspireTableViewCell.swift
//  pInspire
//
//  Created by 臧晓雪 on 4/29/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit

class pInspireTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var questionLabelView: UILabel!
    @IBOutlet var choiceButtonView: [UIButton]! 
    @IBOutlet weak var questionLableView: UILabel!
    
    @IBAction func pressChoiceButton(_ sender: UIButton) {
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
