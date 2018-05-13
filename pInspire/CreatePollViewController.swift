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
    
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton! {
        didSet{
            doneButton.tintColor = #colorLiteral(red: 0.9137254902, green: 0.137254902, blue: 0.2196078431, alpha: 1)
        }
    }
    @IBOutlet weak var pollQuestion: UITextView!
    @IBOutlet weak var anonymousSwitch: UISwitch! {
        didSet {
            anonymousSwitch.onTintColor = #colorLiteral(red: 0.9568627451, green: 0.4078431373, blue: 0.2235294118, alpha: 1)
            anonymousSwitch.isOn = false
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        for view in self.view.subviewsRecursive() {
            if view.isFirstResponder {
                view.endEditing(true)
                updateDoneButtonState()
            }
        }
    }
    
    @IBAction func addAnswerChoice(_ sender: UIButton) {
        let newIndexPath = IndexPath(row: choices.count, section: 0)
        choices.append(Choice())
        choicesTable.insertRows(at: [newIndexPath], with: .automatic)
        if choices.count == 4 {
            
        }
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
        return choices.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == choices.count {
            let cellIdentifier = "AddChoiceCellUnit"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UITableViewCell  else {
                fatalError("The dequeued cell is not an instance of UITableViewCell.")
            }
            return cell
        } else {
            let cellIdentifier = "ChoiceCellUnit"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CreatePollTableViewCell  else {
                fatalError("The dequeued cell is not an instance of CreatePollTableViewCell.")
            }
            let choice = choices[indexPath.row]
            cell.choiceContent.text = choice.content
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == choices.count {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            choices.remove(at: indexPath.row)
            choicesTable.deleteRows(at: [indexPath], with: .fade)
            updateDoneButtonState()
        }
    }
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: UIButton) {
        if let question = pollQuestion.text {
            let isAnonymous = anonymousSwitch.isOn
            for row in 0..<choices.count {
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
            
            writeNewPoll(question: question, choices: choices, user: userName!, isAnonymous: isAnonymous)
        }
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    
    func updateDoneButtonState() {
        let text = pollQuestion.text ?? ""
        var nonEmptyChoices = 0
        for row in 0..<choices.count {
            let indexPath = IndexPath(row: row, section: 0)
            guard let cell = choicesTable.cellForRow(at: indexPath) as? CreatePollTableViewCell else {
                fatalError("The referenced cell is not an instance of CreatePollTableViewCell.")
            }
            if cell.choiceContent.text != "" {
                nonEmptyChoices += 1
            }
        }
        doneButton.isEnabled = !text.isEmpty && nonEmptyChoices > 1
    }
    
    func writeNewPoll(question: String, choices: [Choice], user: String, isAnonymous: Bool) {
        // Create new post at /Polls/$key
        var choicesDict = [String: Dictionary<String, Bool>]()
        for choice in choices {
            if choice.content != ""{
                choicesDict[choice.content] = ["dummy": false]
            }
        }
        
        let key = refPoll.child("Polls").childByAutoId().key
        let newPoll = ["Question": question,
                       "Choices": choicesDict,
                       "Anonymity": isAnonymous,
                       "Initiator": user] as [String : Any]
        let childUpdates = ["/Polls/\(key)": newPoll]
        refPoll.updateChildValues(childUpdates)
        
        // Fetch articles
        var articlesDict = [String: Any]()
        let q = question.components(separatedBy: .punctuationCharacters).joined().components(separatedBy: .whitespaces).joined(separator: "%20")
        let count = 3
        let endpoint = "http://contextualwebsearch.com/api/Search/NewsSearchAPI?q=\(q)&count=\(count)&autoCorrect=true"
        let url = URL(string: endpoint)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in

            if (err != nil) {
                print(err!)
            } else {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary{
                        if let results = json["value"] as? [NSDictionary]{
                            var i = 1
                            for result in results{
                                var source = "Source"+String(i)
                                if let provider = result["provider"] as? NSDictionary, let name = provider["name"] as? String{
                                    source = name.capitalized
                                }
                                var url = "https://google.com"
                                if let link = result["url"] as? String{
                                    url = link
                                }
                                articlesDict[source] = url
                                i+=1
                            }
                            let updaterefpoll = self.refPoll.child("Polls").child(key).child("URL")
                            updaterefpoll.updateChildValues(articlesDict)
                        }
                    }
                } catch let error as NSError {
                    print(error.debugDescription)
                }
            }

        }.resume()
        
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

extension UIView {
    
    func subviewsRecursive() -> [UIView] {
        return subviews + subviews.flatMap { $0.subviewsRecursive() }
    }
    
}

