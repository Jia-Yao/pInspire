//
//  AddContactsTableViewCell.swift
//  pInspire
//
//  Created by Jia Yao on 5/13/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit
import Firebase

protocol AddContactsTableViewCellDelegate : class {
    func didAddContact(_ sender: AddContactsTableViewCell)
}

class AddContactsTableViewCell: UITableViewCell {

    var my_id = "dummy"
    var my_name = "dummy"
    var friend_id = "dummy"
    var refUser: DatabaseReference!
    
    @IBOutlet weak var ProfilePhoto: UIImageView!
    
    @IBOutlet weak var Name: UILabel!
    
    @IBOutlet weak var Label: UILabel!
    
    @IBOutlet weak var AddButton: UIButton!{
        didSet{
            AddButton.tintColor = #colorLiteral(red: 0.9137254902, green: 0.137254902, blue: 0.2196078431, alpha: 1)
        }
    }
    
    weak var delegate: AddContactsTableViewCellDelegate?
    
    @IBAction func AddContact(_ sender: UIButton) {
        Analytics.logEvent("press_add_contact", parameters: ["user": my_id, "time": getCurrentTime()])
        refUser.child(my_id).child("Friends").child(friend_id).setValue(Name.text)
        refUser.child(friend_id).child("Friends").child(my_id).setValue(my_name)
        delegate?.didAddContact(self)
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
