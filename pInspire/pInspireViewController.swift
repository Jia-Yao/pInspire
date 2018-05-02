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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // configureDatabase()
        // self.pollTableView.rowHeight = CGFloat(250)
        // delegate and data source
        self.pollTableView.delegate = self
        self.pollTableView.dataSource = self
        
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
    
    func didTapChoice(_ sender: pInspireTableViewCell, button: UIButton) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        print("pressed button", tappedIndexPath)
        // updateModelAndWriteData()
        let poll = pollTimeline[tappedIndexPath.row]
        let choices = poll.choices
        for indexOfChoice in 0..<choices.count {
            let choice = choices[indexOfChoice]
            let button = sender.choiceButtonView[indexOfChoice]
            button.setTitle("\(choice.content) (\(choice.numOfVotes))", for: UIControlState.normal)
            button.isEnabled = false
        }
        button.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        sender.statsButtonView.isHidden = false
    }
    
    /* func updateModelAndWriteData(for poll: Poll, ) {
        
    }*/
    
    func configureDatabase() {
        ref = Database.database().reference()
        // Listen for new messages in the Firebase database
        
        _refHandle = self.ref.child("Polls").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            
            //iterating through all the values
            strongSelf.pollTimeline = [Poll]()
            for poll in snapshot.children.allObjects as! [DataSnapshot] {
                //getting values
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
                let newPoll = Poll(question: (pollQuestion as! String), choices: choices, user: pollInitiator as! String , isAnonymous: pollAnonymous as! Bool)
                
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
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "PollCellUnit"
        let cell = self.pollTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! pInspireTableViewCell
        cell.delegate = self
        
        // Unpack message from Firebase DataSnapshot
        let poll: Poll = self.pollTimeline[indexPath.row]
        cell.questionLabelView.preferredMaxLayoutWidth = self.pollTableView.bounds.width
        cell.questionLabelView.text = "\(poll.question)"
        cell.initiatorLabelView.text = poll.initiatorAnonymous ? "Anonymous" : "\(poll.initiator)"
        for index in 0..<poll.choices.count {
            cell.choiceButtonView[index].setTitle("\(poll.choices[index].content)", for:UIControlState.normal)
        }
        // Hide unnecessary buttons.
        for index in poll.choices.count..<cell.choiceButtonView.count {
            cell.choiceButtonView[index].isHidden = true
        }
        cell.statsButtonView.isHidden = true
        
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
