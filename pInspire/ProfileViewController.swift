//
//  ProfileViewController.swift
//  pInspire
//
//  Created by Jia Yao on 5/5/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit
import FacebookLogin
import Firebase

class ProfileViewController: UIViewController, LoginButtonDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    
    @IBOutlet weak var profileTableView: UITableView!
    var loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
    var me: User?
    var postedPolls: [Poll] = [Poll]()
    var ref: DatabaseReference!
    //MARK: View-related Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileTableView.delegate = self
        profileTableView.dataSource = self
        profileTableView.estimatedRowHeight = 250
        profileTableView.rowHeight = UITableViewAutomaticDimension
        loginButton.center = view.center
        view.addSubview(loginButton)
        loginButton.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // catch my View up to date with what went on while I was off-screen
        self.configureDatabase()
    }
    
    //MARK: LoginButtonDelegate
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        self.performSegue(withIdentifier: "LoggingOut", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1:
                return postedPolls.count
            default:
                return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Posted Polls"
        } else {
            return "Profile"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //getting the index path of selected row
        if let indexPath = tableView.indexPathForSelectedRow {
            if indexPath.section == 1 {
               performSegue(withIdentifier: "showStatsFromProfile", sender: indexPath)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = self.profileTableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ProfileTableViewCell
            // cell.delegate = self
            cell.nameLabel.text = self.me?.userName
            if let _ = self.me?.profilePhoto, let url = URL(string: (self.me?.profilePhoto)!) {
                DispatchQueue.global(qos:.userInitiated).async {
                    let profilePhotoData = try? Data(contentsOf: url)
                    DispatchQueue.main.async {
                        if profilePhotoData != nil{
                            cell.profilePhoto.image = UIImage(data: profilePhotoData!)
                        }
                    }
                }
            }
            return cell
        } else {
            let cell = self.profileTableView.dequeueReusableCell(withIdentifier: "pollCell", for: indexPath)
            cell.textLabel?.text = postedPolls[indexPath.row].question
            return cell
        }
    }
    
    func configureDatabase() {
        let query =  Database.database().reference().child("Polls").child("Polls").queryOrdered(byChild: "InitiatorId").queryEqual(toValue: me!.userId)
        
        query.observe(.value, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            
            //iterating through all the values
            strongSelf.postedPolls = [Poll]()
            for poll in snapshot.children.allObjects as! [DataSnapshot] {
                //getting values
                let pollKey = poll.key
                let pollObject = poll.value as? [String: AnyObject]
                let pollQuestion  = pollObject![pInspireViewController.Constants.PollQuestionFieldName]
                let pollInitiator = pollObject![pInspireViewController.Constants.PollInitiatorFieldName]
                let pollAnonymous = pollObject![pInspireViewController.Constants.PollAnonymousFieldName]
                let pollUrlString = pollObject![pInspireViewController.Constants.pollUrlFieldName]
                
                var choices = [Choice]()
                if let choiceObject = pollObject![pInspireViewController.Constants.PollChoiceFieldName] as? [String: Any] {
                    for (content, votes) in choiceObject {
                        if let votes = votes as? [String:Bool] {
                            let selectedVotes = votes.filter {strongSelf.me!.visibleUserIds.contains($0.key)}
                            
                            choices.append(Choice(for: content, votes: selectedVotes))
                        }
                    }
                }
                //creating poll object with model and fetched values
                let newPoll = Poll(Id: pollKey, question: (pollQuestion as! String), choices: choices, user: pollInitiator as! String , isAnonymous: pollAnonymous as! Bool, urlString: pollUrlString as? String)
                
                //appending it to list
                strongSelf.postedPolls.append(newPoll)
            }
            strongSelf.profileTableView.reloadData()
        })
        
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier ?? "") {
        case "showStatsFromProfile":
            if let statsController = segue.destination as? StatsViewController{
                let clickedIndexPath = sender as! IndexPath
                
                statsController.poll = self.postedPolls[clickedIndexPath.row]
                statsController.userName = me!.userName
                statsController.user = me
            }
        default:
            print("pInspire: Unexpected Segue Identifier; \(segue.identifier ?? "")")
        }
    }

}
