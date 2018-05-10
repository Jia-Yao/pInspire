//
//  DiscussionGroupTableViewController.swift
//  pInspire
//
//  Created by Jia Yao on 5/7/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit
import Firebase

class DiscussionGroupTableViewController: UITableViewController {
    
    
    //MARK: Properties
    var me: User?
    @IBOutlet var groupTable: UITableView!
    var discussionGroups = [GroupInfo]()
    var ref: DatabaseReference!
    fileprivate var _refHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupTable.delegate = self
        groupTable.dataSource = self
        
        configureDatabase()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController!.tabBar.isHidden = false
    }
    
    private func configureDatabase() {
        ref = Database.database().reference().child("Discussions")
        discussionGroups.removeAll()
        _refHandle = self.ref.observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            let group = snapshot.value as! Dictionary<String, AnyObject>
            let groupId = snapshot.key
            let groupMembers = group["Members"] as! [String]
            let pollQuestion = group["Question"] as? String ?? ""
            if let _ = groupMembers.index(of: (self?.me?.userName)!) {
                let newGroup = GroupInfo(pollQuestion: pollQuestion , members: groupMembers, groupId: groupId)
                strongSelf.discussionGroups.append(newGroup)
                
            }
            strongSelf.groupTable.reloadData()
            }
        )
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discussionGroups.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "GroupCellUnit"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DiscussionGroupTableViewCell  else {
            fatalError("The dequeued cell is not an instance of DiscussionGroupTableViewCell.")
        }
        let group = discussionGroups[indexPath.row]
        cell.pollQuestion.text = group.pollQuestion
        cell.groupMembers.text = group.members_list()
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


    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier ?? "") {
        case "ShowDiscussionRoom":
            if let discussionRoomController = segue.destination as? DiscussionRoomViewController,
                let selectedGroupCell = sender as? DiscussionGroupTableViewCell,
                let indexPath = groupTable.indexPath(for: selectedGroupCell){
                    let selectedGroup = discussionGroups[indexPath.row]
                    discussionRoomController.group = selectedGroup
                    discussionRoomController.senderDisplayName = me!.firstName + " " + me!.lastName
                    discussionRoomController.senderId = me!.userId
            }
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "")")
        }
    }


}
