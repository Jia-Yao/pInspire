//
//  AddPollViewController.swift
//  pInspire
//
//  Created by Jia Yao on 4/28/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit
import os.log

class CreatePollViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    //MARK: Properties
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var pollQuestion: UITextField!
    @IBOutlet weak var options: UITableView!
    @IBOutlet weak var anonymousSwitch: UISwitch!
    
    var poll: Poll?
    var choices = [Choice]()
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pollQuestion.delegate = self
        options.delegate = self
        options.dataSource = self
        updateDoneButtonState()
    }
    
    //MARK: UITextFieldDelegate, UITableViewDataSource
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateDoneButtonState()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        doneButton.isEnabled = false
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CreatePollTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CreatePollTableViewCell  else {
            fatalError("The dequeued cell is not an instance of CreatePollTableViewCell.")
        }
        
        return cell
    }
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === doneButton else {
            os_log("The done button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let question = pollQuestion.text ?? ""
        let isAnonymous = anonymousSwitch.isOn
        
        poll = Poll(question: question, choices: choices, user: user, isAnonymous: isAnonymous)
    }
    

    //MARK: Private Methods
    
    private func updateDoneButtonState() {
        let text = pollQuestion.text ?? ""
        doneButton.isEnabled = !text.isEmpty
    }
}

