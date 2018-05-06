//
//  AddPollViewController.swift
//  pInspire
//
//  Created by Jia Yao on 4/28/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit
import os.log
import Firebase

class CreatePollViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {

    //MARK: Properties
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var pollQuestion: UITextView!
    @IBOutlet weak var anonymousSwitch: UISwitch! {
        didSet {
            anonymousSwitch.onTintColor = #colorLiteral(red: 0.9568627451, green: 0.4078431373, blue: 0.2235294118, alpha: 1)
        }
    }
    @IBOutlet weak var choicesTable: UITableView!
    var poll: Poll?
    var choices = [Choice]()
    var user: User?
    var userName: String?
    
    // Database configuration
    var refPoll: DatabaseReference!
    // var refUser: DatabaseReference!
    fileprivate var _refHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pollQuestion.delegate = self
        pollQuestion.becomeFirstResponder()
        pollQuestion.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        pollQuestion.layer.borderWidth = 1
        updateDoneButtonState()
        choices.append(Choice())
        choices.append(Choice())
        refPoll = Database.database().reference().child("Polls")
        // refUser = Database.database().reference().child("Users")
    }
    
    @IBAction func addAnswerChoice(_ sender: UIButton) {
        let newIndexPath = IndexPath(row: choices.count, section: 0)
        choices.append(Choice())
        choicesTable.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    //MARK: UITextViewDelegate
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        pollQuestion.layer.borderColor = UIColor.clear.cgColor
        updateDoneButtonState()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        pollQuestion.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        doneButton.isEnabled = false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //MARK: UITableViewDelegate, UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ChoiceCellUnit"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CreatePollTableViewCell  else {
            fatalError("The dequeued cell is not an instance of CreatePollTableViewCell.")
        }
        let choice = choices[indexPath.row]
        cell.choiceContent.text = choice.content
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            choices.remove(at: indexPath.row)
            choicesTable.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: UIButton) {
        if let question = pollQuestion.text {
            let isAnonymous = anonymousSwitch.isOn
            for row in 0..<choicesTable.numberOfRows(inSection: 0) {
                let indexPath = IndexPath(row: row, section: 0)
                guard let cell = choicesTable.cellForRow(at: indexPath) as? CreatePollTableViewCell else {
                    fatalError("The referenced cell is not an instance of CreatePollTableViewCell.")
                }
                choices[row].content = cell.choiceContent.text ?? ""
            }
            
//            print(question + " " + String(isAnonymous))
//            for row in 0..<choices.count{
//                print (String(row) + " " + choices[row].content)
//            }
            
            // TODO: Save to Firebase
            writeNewPoll(question: question, choices: choices, user: userName!, isAnonymous: isAnonymous)
        }
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    
    private func updateDoneButtonState() {
        let text = pollQuestion.text ?? ""
        doneButton.isEnabled = !text.isEmpty && choices.count > 1
    }
    
    func writeNewPoll(question: String, choices: [Choice], user: String, isAnonymous: Bool) {
        // Create new post at /Polls/$key
        var choicesDict = [String: Dictionary<String, Bool>]()
        for choice in choices {
            choicesDict[choice.content] = ["dummy": false]
        }
        let key = refPoll.child("Polls").childByAutoId().key
        let newPoll = ["Question": question,
                       "Choices": choicesDict,
                    "Anonymity": isAnonymous,
                    "Initiator": user] as [String : Any]
        let childUpdates = ["/Polls/\(key)": newPoll]
        refPoll.updateChildValues(childUpdates)

    }
}
/*
struct answer
struct PostDictAdvanced {
    let question: String
    let anonymity: Bool
    let initiator: String
    let choices: [String]
    let v: [String: UInt64]
    
    init(title: String, categories: [String: UInt64]) {
        self.title = title
        self.categories = categories
    }
}*/

