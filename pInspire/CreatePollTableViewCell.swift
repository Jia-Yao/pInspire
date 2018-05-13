//
//  CreatePollTableViewCell.swift
//  pInspire
//
//  Created by Jia Yao on 4/28/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit

class CreatePollTableViewCell: UITableViewCell, UITextFieldDelegate {

    //MARK: Properties
    
    @IBOutlet weak var choiceContent: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        choiceContent.delegate = self
    }
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let view = self.viewControllerForTableView as? CreatePollViewController{
            view.updateDoneButtonState()
        }
        return true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension UITableViewCell {
    
    var viewControllerForTableView : UIViewController?{
        return ((self.superview as? UITableView)?.delegate as? UIViewController)
    }
    
}
