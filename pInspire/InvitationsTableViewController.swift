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
    var invitationMessages = [Invitation]()
    var refInvitation: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        invitationsTable.delegate = self
        invitationsTable.dataSource = self
        invitationsTable.rowHeight = UITableViewAutomaticDimension;
        invitationsTable.estimatedRowHeight = 44;
        // TODO: - change
        refInvitation = Database.database().reference().child("Invitations").child(me!.userId)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchInvitations()
    }
    
    private func writeSeenInvitationInDatabase(for invitation: Invitation) {
        refInvitation.child(invitation.invitationId).child("seen").setValue(invitation.hasSeen)
    }
    
    private func fetchInvitations() {
        refInvitation.observeSingleEvent(of: .value, with: { snapshot in
            self.invitationMessages.removeAll()
            for invitation in snapshot.children.allObjects as! [DataSnapshot] {
                let invitationId = invitation.key
                if let info = invitation.value as? [String: AnyObject], let name = info["senderName"] as? String, let text = info["text"] as? String, let senderId = info["senderId"] as? String,
                    let hasSeen = info["seen"] as? Bool {
                    let newText = name == "" ? text : name + ": " + text
                    let newInvitation = Invitation(text: newText, hasSeen: hasSeen, senderId: senderId, invitationId: invitationId)
                    self.invitationMessages.append(newInvitation)
                }
            }
            self.invitationsTable.reloadData()
            self.updateBadge()
        })
    }
    
    private func updateBadge() {
        var count = 0
        for item in self.invitationMessages {
            if !item.hasSeen {
                count += 1
            }
        }
        if let tabItems = self.tabBarController?.tabBar.items as NSArray?
        {
            let tabItem = tabItems[2] as! UITabBarItem
            tabItem.badgeValue = count > 0 ? String(count) : nil
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Offline Invitations"
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitationMessages.count
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        
        // If have not seen
        if !invitationMessages[indexPath.row].hasSeen {
            
            // update model and database
            invitationMessages[indexPath.row].hasSeen = true
            writeSeenInvitationInDatabase(for: invitationMessages[indexPath.row])
            
            //getting the current cell view from the index path
            let currentCell = tableView.cellForRow(at: indexPath)! as! InvitationsTableViewCell
            currentCell.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            currentCell.redDot.isHidden = true
            updateBadge()
        }
        
        return false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InvitationMessage", for: indexPath) as? InvitationsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of InvitationsTableViewCell.")
        }
        let row = indexPath.row
        cell.textLabel?.text = invitationMessages[row].textMessage
        //cell.backgroundColor = invitationMessages[row].hasSeen ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        cell.textLabel?.numberOfLines = 0
        if invitationMessages[row].hasSeen {
            cell.redDot.isHidden = true
        } else {
            cell.redDot.isHidden = false
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //getting the index path of selected row
        if let indexPath = tableView.indexPathForSelectedRow {
            // If have not seen
            if !invitationMessages[indexPath.row].hasSeen {
                invitationMessages[indexPath.row].hasSeen = true
                writeSeenInvitationInDatabase(for: invitationMessages[indexPath.row])
                
                //getting the current cell from the index path
                let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
                currentCell.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
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
