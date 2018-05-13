//
//  ContactsTableViewController.swift
//  pInspire
//
//  Created by Jia Yao on 5/5/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit
import Firebase

class ContactsTableViewController: UITableViewController {

    //MARK: Properties
    var me: User?
    var users = [User]()
    var refUser: DatabaseReference!
    @IBOutlet var contactsTable: UITableView!
    
    //MARK: View-related Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsTable.delegate = self
        contactsTable.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchFriends()
    }
    
    func fetchFriends(){
        
        // Get friends ids from database
        refUser.child(me!.userId).child("Friends").observeSingleEvent(of: .value, with: { (snapshot) in
            var friend_ids = [String]()
            if (snapshot.exists()){
                for user in snapshot.children.allObjects as! [DataSnapshot] {
                    friend_ids.append(user.key)
                }
            }
            // Get friends info from database
            self.refUser.observeSingleEvent(of: .value, with: { snapshot in
                self.users.removeAll()
                for user in snapshot.children.allObjects as! [DataSnapshot] {
                    let uId = user.key
                    if friend_ids.contains(uId) {
                        let uInfo = user.value as? [String: AnyObject]
                        let firstName = uInfo!["FirstName"]
                        let lastName = uInfo!["LastName"]
                        let profilePhoto = uInfo!["ProfilePhoto"]
                        let aUser = User(userId: uId, firstName: firstName as! String, lastName: lastName as! String, profilePhoto: profilePhoto as! String)
                        self.users.append(aUser)
                    }
                }
                self.contactsTable.reloadData()
            })
        })
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count+1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cellIdentifier = "MessageCellUnit"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            return cell
        } else{
            let cellIdentifier = "ContactCellUnit"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ContactsTableViewCell  else {
                fatalError("The dequeued cell is not an instance of ContactsTableViewCell.")
            }
            let user = users[indexPath.row-1]
            cell.Name.text = user.firstName + " " + user.lastName
            DispatchQueue.global(qos:.userInitiated).async {
                let profilePhotoData = try? Data(contentsOf: URL(string: user.profilePhoto)!)
                DispatchQueue.main.async {
                    if profilePhotoData != nil{
                        cell.ProfilePhoto.image = UIImage(data: profilePhotoData!)
                    }
                }
            }
            return cell
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier ?? "") {
        case "AddContacts":
            if let addContactsController = segue.destination as? AddContactsTableViewController{
                addContactsController.me = me
                addContactsController.refUser = refUser
            }
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "")")
        }
    }

}
