//
//  DiscussionGroupTableViewCell.swift
//  pInspire
//
//  Created by Jia Yao on 5/7/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit

class DiscussionGroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pollQuestion: UILabel!
    
    @IBOutlet weak var groupMembers: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
