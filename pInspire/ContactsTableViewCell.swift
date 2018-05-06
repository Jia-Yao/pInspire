//
//  ContactsTableViewCell.swift
//  pInspire
//
//  Created by Jia Yao on 5/5/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var FriendName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
