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

    @IBOutlet var pollTableView: UITableView!
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
        self.pollTableView.estimatedRowHeight = 150
        self.pollTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // catch my View up to date with what went on while I was off-screen
        self.configureDatabase()
    }
    
    
    var ref: DatabaseReference!
    fileprivate var _refHandle: DatabaseHandle?
    var pollTimeline = [Poll]()
    var userName = "Amy"
    func didTapChoice(_ sender: pInspireTableViewCell, button: UIButton) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        let poll = pollTimeline[pollTimeline.count - 1 - tappedIndexPath.row]
        let choices = poll.choices
        let choosedButtonIndex = sender.choiceButtonView.index(of: button)
        
        choices[choosedButtonIndex!].addUser(user: userName, isAnonymous: sender.voteAnonymously)
        updateViewForhasVoted(for: sender, withPoll: poll)
        writeVoteData(id: poll.Id, choiceContent: choices[choosedButtonIndex!].content, userName: userName, isAnonymous: sender.voteAnonymously)
    }
    
    func writeVoteData(id: String, choiceContent: String, userName: String, isAnonymous: Bool){
        ref.child("Polls/Polls").child(id).child(Constants.PollChoiceFieldName).child(choiceContent).child(userName).setValue(isAnonymous)
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        // Listen for new messages in the Firebase database
        
        _refHandle = self.ref.child("Polls").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            
            //iterating through all the values
            strongSelf.pollTimeline.removeAll()
            for poll in snapshot.children.allObjects as! [DataSnapshot] {
                //getting values
                let pollKey = poll.key
                let pollObject = poll.value as? [String: AnyObject]
                let pollQuestion  = pollObject![Constants.PollQuestionFieldName]
                let pollInitiator = pollObject![Constants.PollInitiatorFieldName]
                let pollAnonymous = pollObject![Constants.PollAnonymousFieldName]
                var choices = [Choice]()
                if let choiceObject = pollObject![Constants.PollChoiceFieldName] as? [String: Any] {
                    for (content, votes) in choiceObject {
                        if let votes = votes as? [String:Bool] {
                            choices.append(Choice(for: content, votes: votes))
                        }
                    }
                }
                //creating poll object with model and fetched values
                let newPoll = Poll(Id: pollKey, question: (pollQuestion as! String), choices: choices, user: pollInitiator as! String , isAnonymous: pollAnonymous as! Bool)
                
                //appending it to list
                self?.pollTimeline.append(newPoll)
            }

            // strongSelf.pollTableView.insertRows(at: [IndexPath(row: strongSelf.pollTimeline.count-1, section: 0)], with: .automatic)
            //reloading the tableview
            strongSelf.pollTableView.reloadData()
        })
        
    }
    
    deinit {
        if let refHandle = _refHandle {
            self.ref.child("Polls").removeObserver(withHandle: refHandle)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pollTimeline.count
    }

    private struct Constants {
        static let PollQuestionFieldName:String = "Question"
        static let PollChoiceFieldName: String = "Choices"
        static let PollAnonymousFieldName: String = "Anonymity"
        static let PollInitiatorFieldName: String = "Initiator"
        static let PollOptionColorWhenChosen: UIColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        static let PollOptionColorWhenNotChosen: UIColor = #colorLiteral(red: 0.9921568627, green: 0.7333333333, blue: 0.3019607843, alpha: 1)
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
        let userHasVoted = poll.userHasVoted(user: "Amy")
        if userHasVoted {
            updateViewForhasVoted(for: cell, withPoll: poll)
        } else {
            updateViewForNotVote(for: cell, withPoll: poll)
        }
        
        return cell
    }

    func updateViewForNotVote(for cell: pInspireTableViewCell, withPoll poll: Poll) {

        cell.statsButtonView.isHidden = true
        cell.voteAnonymouslySwitch.isHidden = false
        cell.voteLabelView.isHidden = false
        for index in 0..<poll.choices.count {
            let choiceButtonView = cell.choiceButtonView[index]
            choiceButtonView.isHidden = false
            
            let choiceModel = poll.choices[index]
            choiceButtonView.backgroundColor = Constants.PollOptionColorWhenNotChosen
            
            choiceButtonView.setTitle("\(choiceModel.content)", for:UIControlState.normal)
            choiceButtonView.isEnabled = true
        }
        // Hide unnecessary buttons.
        for index in poll.choices.count..<cell.choiceButtonView.count {
            cell.choiceButtonView[index].isHidden = true
        }
    }

    func updateViewForhasVoted(for cell: pInspireTableViewCell, withPoll poll: Poll) {
        cell.statsButtonView.isHidden = false
        cell.voteAnonymouslySwitch.isHidden = true
        cell.voteLabelView.isHidden = true
        for index in 0..<poll.choices.count {
            let choiceButtonView = cell.choiceButtonView[index]
            choiceButtonView.isHidden = false
            
            let choiceModel = poll.choices[index]
            
            if choiceModel.userHasVotedThis(user: userName) {
                choiceButtonView.backgroundColor = Constants.PollOptionColorWhenChosen
            } else {
                choiceButtonView.backgroundColor = Constants.PollOptionColorWhenNotChosen
            }
            let numOfVotes = choiceModel.numOfVotesForUser(for: userName)
            choiceButtonView.setTitle("\(choiceModel.content) (\(numOfVotes))", for: UIControlState.normal)
            choiceButtonView.isEnabled = false
        }
        // Hide unnecessary buttons.
        for index in poll.choices.count..<cell.choiceButtonView.count {
            cell.choiceButtonView[index].isHidden = true
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
        if let identifier = segue.identifier {
            let destination = segue.destination.contents

            if let destination = destination as?  Image {
                
            }
            if identifier ==
        }
    }*/
    
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
