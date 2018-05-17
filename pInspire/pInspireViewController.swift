//
//  TimelineTableViewController.swift
//  pInspire
//
//  Created by Jia Yao on 4/28/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit
import Firebase

class pInspireViewController: UITableViewController, pInspireTableViewCellDelegate {

    //MARK: Properties
    
    @IBOutlet var pollTableView: UITableView!
    var ref: DatabaseReference!
    var refDiscussion: DatabaseReference!
    var refInvitation: DatabaseReference!
    var refUser: DatabaseReference!
    
    fileprivate var _refHandle: DatabaseHandle?
    var pollTimeline = [Poll]()
    var user: User?
    var userName: String?
    var unseenInivitationNum: Int = 0 {
        didSet {
            if let tabItems = self.tabBarController?.tabBar.items as NSArray?
            {
                let tabItem = tabItems[2] as! UITabBarItem
                tabItem.badgeValue = unseenInivitationNum > 0 ? String(unseenInivitationNum) : nil
            }
        }
    }
    
    var unseenMessageNum: Int = 0 {
        didSet {
            if let tabItems = self.tabBarController?.tabBar.items as NSArray?
            {
                let tabItem = tabItems[3] as! UITabBarItem
                tabItem.badgeValue = unseenMessageNum > 0 ? String(unseenMessageNum) : nil
            }
        }
    }
    
    //MARK: View-related Methods
    
    @objc private func handleRefresh(sender refreshControl: UIRefreshControl) {
        configureDatabase()
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // delegate and data source
        self.pollTableView.delegate = self
        self.pollTableView.dataSource = self
        
        // Refresh control
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            let title = NSLocalizedString("PullToRefresh", comment: "Pull to refresh")
            refreshControl.attributedTitle = NSAttributedString(string: title)
            refreshControl.addTarget(self,
                                     action: #selector(handleRefresh(sender:)),
                                     for: .valueChanged)
            self.pollTableView.refreshControl = refreshControl
        }

        // Along with auto layout, these are the keys for enabling variable cell height
        self.pollTableView.estimatedRowHeight = 250
        self.pollTableView.rowHeight = UITableViewAutomaticDimension
        self.configureDatabase()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // catch my View up to date with what went on while I was off-screen
        configureDatabase()
    }
    
    func didTapChoice(_ sender: pInspireTableViewCell, button: UIButton) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        let poll = pollTimeline[pollTimeline.count - 1 - tappedIndexPath.row]
        let choices = poll.choices
        let choosedButtonIndex = sender.choiceButtonView.index(of: button)
        
        if (!sender.visibleVote){
            Analytics.logEvent("vote_anonymous", parameters: ["user": user!.userId, "time": getCurrentTime()])
        } else {
            Analytics.logEvent("vote_public", parameters: ["user": user!.userId, "time": getCurrentTime()])
        }
        choices[choosedButtonIndex!].addUser(userId: user!.userId, isAnonymous: !sender.visibleVote)
        updateViewForhasVoted(for: sender, withPoll: poll)
        writeVoteData(id: poll.Id, choiceContent: choices[choosedButtonIndex!].content, userId: user!.userId, isAnonymous: !sender.visibleVote)
    }
    
    func didTapDiscuss(_ sender: pInspireTableViewCell) {
        Analytics.logEvent("press_discuss", parameters: ["user": user!.userId, "time": getCurrentTime()])
        let clickedIndexPath = self.pollTableView.indexPath(for: (sender as UITableViewCell))!
        let totalCount = self.pollTimeline.count
        let poll = self.pollTimeline[totalCount - 1 - clickedIndexPath.row]
        let members: [String: Bool] = selectDiscussionMembers(from: poll)
        var members_without_self = Array<String>(members.keys)
        members_without_self.remove(at: members_without_self.index(of: user!.userId)!)
        let members_without_self_name: [String] = members_without_self.map {return self.user!.idNameConverter[$0]!}
        
        // Popup dialog box
        let alertController = UIAlertController(title: "START A DICUSSION", message: "pInspire recommends you to dicuss with " + members_without_self_name.joined(separator: ", ") + ". Leave them a message:", preferredStyle: .alert)
        
        let onlineAction = UIAlertAction(title: "Let's chat about it ONLINE", style: .default) { (_) in
            Analytics.logEvent("press_chat_online", parameters: ["user": self.user!.userId, "time": getCurrentTime()])
            var message = alertController.textFields?[0].text
            if message == nil || message == "" {
                message = "The poll \"" + poll.question + "\" is so interesting, let's chat about it ONLINE!"
            } else {
                message = message! + " Let's chat about it ONLINE!"
            }
            let _ = self.createGroupIdToDatabase(for: members, from: poll, message: message!)
            self.tabBarController!.selectedIndex = 3
        }
        
        let offlineAction = UIAlertAction(title: "Let's chat about it OFFLINE", style: .default) { (_) in
            Analytics.logEvent("press_chat_offline", parameters: ["user": self.user!.userId, "time": getCurrentTime()])
            var message = alertController.textFields?[0].text
            if message == nil || message == "" {
                message = "The poll \"" + poll.question + "\" is so interesting, let's chat about it OFFLINE!"
            } else {
                message = message! + " Let's chat about it OFFLINE!"
            }
            self.createInvitationToDatabase(from: (self.user?.userId)!, to: members_without_self, message: message!)
            let alert = UIAlertController(title: "Invitations Sent!", message: "", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            // Hide in 2 seconds
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in Analytics.logEvent("press_discuss_cancel", parameters: ["user": self.user!.userId, "time": getCurrentTime()])}
        
        alertController.addTextField { (textField) in
            textField.placeholder = "This poll is so interesting, ..."
        }
        alertController.addAction(onlineAction)
        alertController.addAction(offlineAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func didTapStats(_ sender: pInspireTableViewCell) {
        Analytics.logEvent("press_stats", parameters: ["user": user!.userId, "time": getCurrentTime()])
        performSegue(withIdentifier: "showStats", sender: sender)
    }
    
    func didTapReadMore(_ sender: pInspireTableViewCell) {
        Analytics.logEvent("press_read", parameters: ["user": user!.userId, "time": getCurrentTime()])
        performSegue(withIdentifier: "showWeb", sender: sender)
    }
    
    private func selectDiscussionMembers(from poll: Poll) -> [String: Bool] {
        var members = poll.visibleVotedUserIds
        members.remove(at: members.index(of: user!.userId)!)
        members.shuffle()
        let selectNumOfMembers = min(Constants.chatMemberUpperLimit, poll.numOfVisibleVotedUsers)
        var selectedDict = [String: Bool]()
        for memberId in Array(members[0..<selectNumOfMembers]) {
            selectedDict[memberId] = false
        }
        selectedDict.updateValue(true, forKey: user!.userId)
        return selectedDict
        
        /* while (members.count < Constants.chatMemberUpperLimit) && (members.count < (poll?.numOfVisibleVotedUsers)!) {
         Can do some smarter way here.
         }*/
    }

    private func createGroupIdToDatabase(for members: [String: Bool], from poll: Poll, message: String) -> String {
        let itemRef: DatabaseReference = refDiscussion.childByAutoId()
        let key = itemRef.key
        let newDiscussion = ["Members": members, "Question": poll.question] as [String: Any]
        let childUpdates = ["/\(key)": newDiscussion]
        refDiscussion.updateChildValues(childUpdates)
        let messageRef = itemRef.child("Messages").childByAutoId()
        let messageContent = ["senderId": user!.userId, "senderName": userName!, "text": message, "hasSeen": members] as [String : Any]
        messageRef.setValue(messageContent)
        return itemRef.key
    }
    
    private func createInvitationToDatabase(from sender: String, to receivers: [String], message: String) {
        for receiver in receivers{
            let key = refInvitation.child(receiver).childByAutoId()
            let newMessage = ["senderId": user!.userId, "senderName": userName!, "text": message, "seen": false] as [String : Any]
            key.setValue(newMessage)
        }
    }
    
    private func readDiscussionFromDatabase() {
        refDiscussion.observe(.value, with: { [weak self] (snapshot) -> Void in
            var countUnseen = 0
            for discuss in snapshot.children.allObjects as! [DataSnapshot] {
                //getting values
                // print("\(discuss)")
               
                if let discussObject = discuss.value as? [String: AnyObject] {
                
                    let memberDict = discussObject["Members"]
                    let messagesObject = discussObject["Messages"]
                    if let memberHasSeen = memberDict as? [String: Bool], let chatRoomHasSeen = memberHasSeen[(self?.user?.userId)!] {
                    if !chatRoomHasSeen {
                        countUnseen += 1
                        continue
                    } else {
                    
                        for (_, value) in (messagesObject as? [String: AnyObject]) ?? [:] {
                            if let message = value as? [String: AnyObject] {
                                if let messageHasSeen = message["hasSeen"] as?  [String: Bool], messageHasSeen[(self?.user?.userId)!]! == false {
                                    countUnseen += 1
                                    break
                                }
                            }
                        }
                    }
                }
            }
            }
            self?.unseenMessageNum = countUnseen
        })
    }
    
    private func readInvitationFromDatabase() {
        let query = refInvitation.queryOrderedByKey().queryEqual(toValue: user!.userId)
        
        query.observe(.value, with: { (snapshot) in
            var count: Int = 0
            for childSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                if let invitationObject = childSnapshot.value as? [String: AnyObject]{
                    for (_, value) in invitationObject {
                        let seenObject = value as? [String: Any]
                        let hasSeen = seenObject!["seen"] as? Bool
                        if hasSeen == false {
                            count += 1
                        }
                    }
                }
            }
            // set Badge value
            self.unseenInivitationNum = count
        })
    }
    
    
    private func writeVoteData(id: String, choiceContent: String, userId: String, isAnonymous: Bool){
        ref.child("Polls/Polls").child(id).child(Constants.PollChoiceFieldName).child(choiceContent).child(userId).setValue(!isAnonymous)
    }
    
    func selectVisibleVotes(from votes: [String: Bool]) -> [String: Bool]{
        return votes.filter {user!.visibleUserIds.contains($0.key)}
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        refDiscussion = Database.database().reference().child("Discussions")
        refInvitation = Database.database().reference().child("Invitations")
        refUser = Database.database().reference().child("Users")
        
        // Listen for new messages in the Firebase database
        readInvitationFromDatabase()
        readDiscussionFromDatabase()
        
        refUser.child(self.user!.userId).child("Friends").observeSingleEvent(of: .value, with: { (snapshot) in
            self.user!.friendsDict = [String: String]()
            if (snapshot.exists()){
                for user in snapshot.children.allObjects as! [DataSnapshot] {
                    self.user!.friendsDict![user.key] = (user.value as! String)
                }
            }
                
            self._refHandle = self.ref.child("Polls").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
                guard let strongSelf = self else { return }
                //iterating through all the values
                strongSelf.pollTimeline.removeAll()
                for poll in snapshot.children.allObjects as! [DataSnapshot] {
                    //getting values
                    let pollKey = poll.key
                    let pollObject = poll.value as? [String: AnyObject]
                    let pollQuestion  = pollObject![Constants.PollQuestionFieldName]
                    let pollInitiator = pollObject![Constants.PollInitiatorFieldName]
                    let pollInitiatorId = pollObject![Constants.PollInitiatorIdFieldName]
                    let pollAnonymous = pollObject![Constants.PollAnonymousFieldName]
                    let pollUrlString = pollObject![Constants.pollUrlFieldName]
                    if let initiatorId = pollInitiatorId as? String {
                        if !(self?.user?.visibleUserIds.contains(initiatorId))! {
                            continue
                        }
                    }
                    // TODO: - uncomment below when done.
                    /*else {
                        continue
                    }*/
                    var choices = [Choice]()
                    if let choiceObject = pollObject![Constants.PollChoiceFieldName] as? [String: Any] {
                        for (content, votes) in choiceObject {
                            if let votes = votes as? [String:Bool] {
                                let selectedVotes = strongSelf.selectVisibleVotes(from: votes)
                                choices.append(Choice(for: content, votes: selectedVotes))
                            }
                        }
                    }
                    
                    //creating poll object with model and fetched values
                    let newPoll = Poll(Id: pollKey, question: (pollQuestion as! String), choices: choices, user: pollInitiator as! String , isAnonymous: pollAnonymous as! Bool, urlString: pollUrlString as? String)
                    
                    //appending it to list
                    self?.pollTimeline.append(newPoll)
                }

                // strongSelf.pollTableView.insertRows(at: [IndexPath(row: strongSelf.pollTimeline.count-1, section: 0)], with: .automatic)
                //reloading the tableview
                strongSelf.pollTableView.reloadData()
            })
        })
            
    }
    
    deinit {
        if let refHandle = _refHandle {
            self.ref.child("Polls").removeObserver(withHandle: refHandle)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pollTimeline.count
    }

    struct Constants {
        static let chatMemberUpperLimit = 2
        static let PollQuestionFieldName:String = "Question"
        static let pollUrlFieldName: String = "URL"
        static let PollChoiceFieldName: String = "Choices"
        static let PollAnonymousFieldName: String = "Anonymity"
        static let PollInitiatorFieldName: String = "Initiator"
        static let PollInitiatorIdFieldName: String = "InitiatorId"
        static let PollOptionColorWhenChosen: UIColor = #colorLiteral(red: 0.3098039216, green: 0.3411764706, blue: 0.6588235294, alpha: 1)
        static let PollOptionColorWhenNotChosen: UIColor = #colorLiteral(red: 0.3098039216, green: 0.3411764706, blue: 0.6588235294, alpha: 1)
        static let PollSwitchColor: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        static let TabBarBackgroundColor: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "PollCellUnit"
        let cell = self.pollTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! pInspireTableViewCell
        cell.delegate = self
        
        // Unpack message from Firebase DataSnapshot
        let totalCount = self.pollTimeline.count
        let poll: Poll = self.pollTimeline[totalCount - 1 - indexPath.row]
        cell.questionLabelView.preferredMaxLayoutWidth = self.pollTableView.bounds.width
        cell.questionLabelView.text = "\(poll.question)"
        cell.initiatorLabelView.text = poll.initiatorAnonymous ? "Anonymous" : "\(poll.initiator)"
        let userHasVoted = poll.userHasVoted(userId: user!.userId)
        if userHasVoted {
            updateViewForhasVoted(for: cell, withPoll: poll)
        } else {
            updateViewForNotVote(for: cell, withPoll: poll)
        }
        return cell
    }

    func modifyChoiceContentForDisplay(for content: String) -> String {
        if content == "1&&&&&&&&" {
            return "1"
        } else if content == "0&&&&&&&&" {
            return "0"
        } else if content == "2&&&&&&&&" {
            return "2"
        }
        return content
    }
    
    func updateViewForNotVote(for cell: pInspireTableViewCell, withPoll poll: Poll) {

        cell.statsButtonView.isHidden = true
        cell.discussButtonView.isHidden = true
        cell.voteAnonymouslySwitch.isHidden = false
        cell.voteLabelView.isHidden = false

        for index in 0..<poll.choices.count {
            let choiceButtonView = cell.choiceButtonView[index]
            choiceButtonView.isHidden = false
            
            let choiceModel = poll.choices[index]
            choiceButtonView.backgroundColor = Constants.PollOptionColorWhenNotChosen
            
            let buttonTitle = modifyChoiceContentForDisplay(for: choiceModel.content)
            
            choiceButtonView.setTitle("\(buttonTitle)", for:UIControlState.normal)
            choiceButtonView.isEnabled = true
            choiceButtonView.titleLabel?.textAlignment = .center
            choiceButtonView.titleLabel?.numberOfLines = 2
            choiceButtonView.setImage(nil , for: .normal)
            // choiceButtonView.sizeToFit()
        }
        // Hide unnecessary buttons.
        for index in poll.choices.count..<cell.choiceButtonView.count {
            cell.choiceButtonView[index].isHidden = true
        }
    }

    func updateViewForhasVoted(for cell: pInspireTableViewCell, withPoll poll: Poll) {
        cell.statsButtonView.isHidden = false
        cell.discussButtonView.isHidden = false
        cell.voteAnonymouslySwitch.isHidden = true
        cell.voteLabelView.isHidden = true
        let hasAnonymouslyVoted = !poll.visibleVotedUserIds.contains(user!.userId)
        for index in 0..<poll.choices.count {
            let choiceButtonView = cell.choiceButtonView[index]
            choiceButtonView.isHidden = false
            
            let choiceModel = poll.choices[index]
            
            if choiceModel.userHasVotedThis(userId: user!.userId) {
                choiceButtonView.backgroundColor = Constants.PollOptionColorWhenChosen
                if (hasAnonymouslyVoted){
                    let img = UIImage(named: "anonymous")
                    choiceButtonView.setImage(img , for: .normal)
                } else {
                    let img = UIImage(named: "checkmark")
                    choiceButtonView.setImage(img , for: .normal)
                }
            } else {
                choiceButtonView.backgroundColor = Constants.PollOptionColorWhenNotChosen
                choiceButtonView.setImage(nil , for: .normal)
            }
            let numOfVotes = choiceModel.numOfVotesForMe(for: userName!)
            let buttonTitle = modifyChoiceContentForDisplay(for: choiceModel.content)
            choiceButtonView.setTitle("\(buttonTitle) (\(numOfVotes))", for: UIControlState.normal)
            choiceButtonView.isEnabled = false
            choiceButtonView.titleLabel?.textAlignment = .center
            // choiceButtonView.titleLabel?.numberOfLines = 2
            // choiceButtonView.sizeToFit()
        }
        // Hide unnecessary buttons.
        for index in poll.choices.count..<cell.choiceButtonView.count {
            cell.choiceButtonView[index].isHidden = true
        }
        if poll.numOfVisibleVotedUsers < 3 || hasAnonymouslyVoted {
            cell.discussButtonView.isHidden = true
            // cell.discussButtonView.alpha = 0.5;
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
        case "CreatePoll":
            if let createPollController = segue.destination as? CreatePollViewController{
                createPollController.user = user
                createPollController.userName = userName
            }
        case "showStats":
            if let statsController = segue.destination as? StatsViewController{
                let clickedIndexPath = self.pollTableView.indexPath(for: (sender as! UITableViewCell))!
                let totalCount = self.pollTimeline.count
                statsController.poll = self.pollTimeline[totalCount - 1 - clickedIndexPath.row]
                statsController.userName = userName
                statsController.user = user
            }
        case "showWeb":
            if let stateController = segue.destination as? WebViewController {
                let clickedIndexPath = self.pollTableView.indexPath(for: (sender as! UITableViewCell))!
                let totalCount = self.pollTimeline.count
//                stateController.urlString = self.pollTimeline[totalCount - 1 - clickedIndexPath.row].urlString
                stateController.refPoll = self.ref.child("Polls/Polls").child(self.pollTimeline[totalCount - 1 - clickedIndexPath.row].Id).child(Constants.pollUrlFieldName)
            }
        default:
            print("pInspire: Unexpected Segue Identifier; \(segue.identifier ?? "")")
        }
    }
    
}

extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}
