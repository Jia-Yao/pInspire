//
//  StatsViewController.swift
//  pInspire
//
//  Created by 臧晓雪 on 5/8/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit
import Firebase

class StatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var questionLabelView: UILabel! {
        didSet {
            questionLabelView.layer.borderWidth = 3.0
            questionLabelView.layer.cornerRadius = 8
            questionLabelView.layer.borderColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
            questionLabelView.backgroundColor = UIColor.white
            questionLabelView.layer.masksToBounds = true
        }
    }
    
    
    @IBOutlet weak var nameTableView: UITableView!
    
    @IBOutlet var choicesView: [StatsView]!
    
    
    var refDiscussion: DatabaseReference!
    
    var poll: Poll? {
        didSet {
            updateView()
        }
    }
    
    var userName: String?
    var user: User?
    
    private var clickedChoice: Choice? = nil {
        didSet {
            self.nameTableView.reloadData()
        }
    }
    
    private var people: [String]? {
        return clickedChoice?.visibleUsersForMe(user: user?.userName ?? "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTableView.delegate = self
        nameTableView.dataSource = self
        refDiscussion = Database.database().reference().child("Discussions")
        updateView()
        
    }
    
    var totalVotes: Int = 0
    
    private func updateView() {
        if questionLabelView != nil, let poll = poll {
            questionLabelView.text = "\(poll.question)"
            totalVotes = poll.numOfVotes
            for index in 0..<poll.choices.count {
                let choiceView = choicesView[index]
                let choice = poll.choices[index]
                addGestureToChoiceView(for: choiceView)
                updateChoiceView(for: choiceView, model: choice)
            }
            for index in poll.choices.count..<self.choicesView.count {
                self.choicesView[index].isHidden = true
            }
        }
    }

    func addGestureToChoiceView(for barView: StatsView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapBar(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        barView.addGestureRecognizer(tap)
    }
    
    @objc func tapBar(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if  let barView = sender.view as? StatsView {
                let tappedIndex = choicesView.index(of: barView)
                updateClickedInView(clickedIndex: tappedIndex!)
                clickedChoice = barView.clicked ? poll?.choices[tappedIndex!] : nil
            }
        }
    }
    
    func updateClickedInView(clickedIndex: Int) {
        if let poll = poll {
            for index in 0..<poll.choices.count {
                let barView = choicesView[index]
                if index == clickedIndex {
                    barView.clicked = !barView.clicked
                } else {
                    barView.clicked = false
                }
            }
        }
    }
    
    private func updateChoiceView(for choiceView: StatsView, model choice: Choice) {
        choiceView.context = choice.content
        choiceView.ratio = Float(choice.numOfVotes) / Float(totalVotes)
        choiceView.chosen = choice.containUserVote(user: userName!)
    }
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Who Voted This Option"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "NameCellUnit"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let name = people![indexPath.row]
        cell.textLabel?.text = name
        return cell
    }
    
    private func createGroupIdToDatabase(for members: [String]) -> String {
        let itemRef: DatabaseReference = refDiscussion.childByAutoId()
        // itemRef.setValue("Messages")
        let key = itemRef.key
        let newDiscussion = ["Members": members, "Message": [], "Question": self.poll?.question ?? ""] as [String: Any]
        let childUpdates = ["/\(key)": newDiscussion]
        refDiscussion.updateChildValues(childUpdates)
        return itemRef.key
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier ?? "") {
        
        default:
            print("pInspire: Unexpected Segue Identifier; \(segue.identifier ?? "")")
        }
    }
    
    
}
