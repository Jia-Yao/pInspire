//
//  InvitationsTableViewCell.swift
//  pInspire
//
//  Created by Jia Yao on 5/16/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit

class InvitationsTableViewCell: UITableViewCell {

    @IBOutlet weak var redDot: UIImageView! {
        didSet {
            redDot.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
