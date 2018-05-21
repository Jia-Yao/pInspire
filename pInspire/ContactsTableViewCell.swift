//
//  ContactsTableViewCell.swift
//  pInspire
//
//  Created by Jia Yao on 5/5/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit
import Firebase

protocol ContactsTableViewCellDelegate : class {
    func didBlockContact(_ sender: ContactsTableViewCell)
}

class ContactsTableViewCell: UITableViewCell {

    var my_id = "dummy"
    var friend_id = "dummy"
    var refUser: DatabaseReference!
    
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var ProfilePhoto: UIImageView!
    
    weak var delegate: ContactsTableViewCellDelegate?
    @IBAction func block(_ sender: UIButton) {
        refUser.child(my_id).child("Blacklist").child(friend_id).setValue(Name.text)
        refUser.child(my_id).child("Friends").child(friend_id).removeValue()
        refUser.child(friend_id).child("Friends").child(my_id).removeValue()
        delegate?.didBlockContact(self)
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
