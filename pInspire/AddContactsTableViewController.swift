//
//  AddContactsTableViewController.swift
//  pInspire
//
//  Created by Jia Yao on 5/13/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore

class AddContactsTableViewController: UITableViewController, AddContactsTableViewCellDelegate {
    
    //MARK: Properties
    var me: User?
    var users = [User]()
    var refUser: DatabaseReference!
    var refInvitation: DatabaseReference!
    @IBOutlet var usersTable: UITableView!
    var facebook_friends_ids = [String]()
    var blacklist_ids = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTable.delegate = self
        usersTable.delegate = self
        refInvitation = Database.database().reference().child("Invitations")
        fetchUsers()
    }
    
    func fetchUsers(){
        // Get Facebook friends ids
//        let parameters = ["fields": "id, first_name, last_name, picture.type(large)"]
//        let req = GraphRequest(graphPath: "/me/friends", parameters: parameters)
//        req.start{ (response, result) in
//            switch result {
//            case .success(let value):
//                if value.dictionaryValue != nil, let fb_friends = value.dictionaryValue!["data"] as? [NSDictionary]{
//                    for fb_friend in fb_friends{
//                        self.facebook_friends_ids.append(fb_friend.value(forKey: "id") as! String)
//                    }
//                }
//
//            case .failed(let error):
//                print(error)
//            }
        // Get blacklist from database
        self.refUser.child(self.me!.userId).child("Blacklist").observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()){
                for user in snapshot.children.allObjects as! [DataSnapshot] {
                    self.blacklist_ids.append(user.key)
                }
            }
            
            // Get friends ids from database
            self.refUser.child(self.me!.userId).child("Friends").observeSingleEvent(of: .value, with: { (snapshot) in
                var already_friends_ids = [String]()
                if (snapshot.exists()){
                    for user in snapshot.children.allObjects as! [DataSnapshot] {
                        already_friends_ids.append(user.key)
                    }
                }
                
                // Get all user info from database
                self.refUser.observeSingleEvent(of: .value, with: { snapshot in
                    self.users.removeAll()
                    for user in snapshot.children.allObjects as! [DataSnapshot] {
                        let uId = user.key
                        if self.me!.userId != uId && !already_friends_ids.contains(uId) {
                            let uInfo = user.value as? [String: AnyObject]
                            let firstName = uInfo!["FirstName"]
                            let lastName = uInfo!["LastName"]
                            let profilePhoto = uInfo!["ProfilePhoto"]
                            let aUser = User(userId: uId, firstName: firstName as! String, lastName: lastName as! String, profilePhoto: profilePhoto as! String)
                            if self.facebook_friends_ids.contains(uId){
                                self.users.insert(aUser, at: 0)
                            } else {
                                self.users.append(aUser)
                            }
                        }
                    }
                    self.usersTable.reloadData()
                })
            })
        })
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "People You May Know"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "ContactCellUnit"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AddContactsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of AddContactsTableViewCell.")
        }
        let user = users[indexPath.row]
        cell.delegate = self
        cell.my_id = me!.userId
        cell.my_name = me!.userName
        cell.friend_id = user.userId
        cell.refUser = refUser
        cell.refInvitation = refInvitation
        cell.Name.text = user.firstName + " " + user.lastName
        if facebook_friends_ids.contains(user.userId){
            cell.Label.text = "Facebook Friend"
        } else if blacklist_ids.contains(user.userId){
            cell.Label.text = "Blacklisted by you"
        } else {
            cell.Label.text = "pInspire User"
        }
        DispatchQueue.global(qos:.userInitiated).async {
            let profilePhotoData = try? Data(contentsOf: URL(string: user.profilePhoto)!)
            DispatchQueue.main.async {
                if profilePhotoData != nil{
                    cell.ProfilePhoto.image = UIImage(data: profilePhotoData!)
                }
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func didAddContact(_ sender: AddContactsTableViewCell) {
        if let tappedIndexPath = usersTable.indexPath(for: sender){
            users.remove(at: tappedIndexPath.row)
            usersTable.deleteRows(at: [tappedIndexPath], with: .top)
        }
    }
    
    func triedAddContactWasBlocked(_ sender: AddContactsTableViewCell) {
        let alert = UIAlertController(title: "You have been blocked by this user", message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        // Hide in 2 seconds
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
