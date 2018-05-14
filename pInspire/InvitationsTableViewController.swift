//
//  InvitationsTableViewController.swift
//  pInspire
//
//  Created by Jia Yao on 5/13/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit
import Firebase

class InvitationsTableViewController: UITableViewController {

    @IBOutlet var invitationsTable: UITableView!
    var me: User?
    var invitationMessages = [String]()
    var refInvitation: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        invitationsTable.delegate = self
        invitationsTable.dataSource = self
        invitationsTable.rowHeight = UITableViewAutomaticDimension;
        invitationsTable.estimatedRowHeight = 44;
        refInvitation = Database.database().reference().child("Invitations").child(me!.userName)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchInvitations()
    }
    
    private func fetchInvitations() {
        refInvitation.observeSingleEvent(of: .value, with: { snapshot in
            self.invitationMessages.removeAll()
            for invitation in snapshot.children.allObjects as! [DataSnapshot] {
                if let info = invitation.value as? [String: AnyObject], let name = info["senderName"] as? String, let text = info["text"] as? String{
                    self.invitationMessages.append(name + ": " + text)
                }
            }
            self.invitationsTable.reloadData()
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Offline Invitations"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitationMessages.count
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvitationMessage", for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = invitationMessages[row]
        cell.textLabel?.numberOfLines = 0
        return cell
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
