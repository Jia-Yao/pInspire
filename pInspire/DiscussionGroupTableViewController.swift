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
        groupTable.rowHeight = UITableViewAutomaticDimension;
        groupTable.estimatedRowHeight = 44;
        
        // Refresh control
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            let title = NSLocalizedString("PullToRefresh", comment: "Pull to refresh")
            refreshControl.attributedTitle = NSAttributedString(string: title)
            refreshControl.addTarget(self,
                                     action: #selector(handleRefresh(sender:)),
                                     for: .valueChanged)
            self.groupTable.refreshControl = refreshControl
        }
    }
    
    @objc private func handleRefresh(sender refreshControl: UIRefreshControl) {
        configureDatabase()
        refreshControl.endRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController!.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // catch my View up to date with what went on while I was off-screen
        self.configureDatabase()
    }
    
    private func configureDatabase() {
        ref = Database.database().reference().child("Discussions")
        discussionGroups.removeAll()
        _refHandle = self.ref.observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            
            let group = snapshot.value as! Dictionary<String, AnyObject>
            let groupId = snapshot.key
            let groupMemberDict = group["Members"] as! [String: Bool]
            
            let messagesObject = group["Messages"] as! [String: AnyObject]
            if let chatRoomHasSeen = (groupMemberDict[(strongSelf.me?.userId)!]) {
                var hasSeen = true
                if !chatRoomHasSeen {
                    hasSeen = false
                } else {
                    for (_, value) in messagesObject {
                        if let message = value as? [String: AnyObject] {
                            if let messageHasSeen = message["hasSeen"] as? [String: Bool]{
                                if messageHasSeen[(strongSelf.me?.userId)!]! == false {
                                    hasSeen = false
                                    break
                                }
                            }
                        }
                    }
                }
                let groupMemberIds = Array<String>(groupMemberDict.keys)
                let groupMembers = groupMemberIds.map {return (strongSelf.me!.idNameConverter[$0])!}
                let pollQuestion = group["Question"] as? String ?? ""
                if let _ = groupMembers.index(of: (strongSelf.me?.userName)!) {
                    let newGroup = GroupInfo(pollQuestion: pollQuestion , members: groupMembers, memberIds: groupMemberIds, groupId: groupId, hasSeen: hasSeen)
                    strongSelf.discussionGroups.append(newGroup)
                }
            }
            strongSelf.groupTable.reloadData()
            }
        )
    }
    
    private func setGroupChatAsRead(for groupChat: GroupInfo) {
        let groupId = groupChat.groupId
        let refGroupChat = Database.database().reference().child("Discussions").child(groupId)
        refGroupChat.child("Members").child((me?.userId)!).setValue(true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Online Discussions"
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
        cell.pollQuestion.numberOfLines = 0
        cell.groupMembers.text = group.members_list()
        cell.groupMembers.numberOfLines = 0
        cell.backgroundColor = group.hasSeen ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
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
                    setGroupChatAsRead(for: selectedGroup)
                    discussionRoomController.group = selectedGroup
                    discussionRoomController.senderDisplayName = me!.userName
                    discussionRoomController.senderId = me!.userId
            }
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "")")
        }
    }


}
