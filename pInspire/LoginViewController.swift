//
//  LoginViewController.swift
//  pInspire
//
//  Created by Jia Yao on 5/5/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import Firebase

class LoginViewController: UIViewController, LoginButtonDelegate {
    
    //MARK: Properties
    
    var loginButton = LoginButton(readPermissions: [ .publicProfile, .userFriends ])
    var user = User(userId: "", firstName: "", lastName: "", profilePhoto: "")
    var refUser: DatabaseReference!
    
    //MARK: View-related Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.center = view.center
        view.addSubview(loginButton)
        loginButton.delegate = self
        
        if AccessToken.current != nil{
            // User is already logged in
            loginButton.isHidden = true
        }
        
        refUser = Database.database().reference().child("Users")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if AccessToken.current != nil{
            // User is already logged in
            fetchProfile()
        }
    }
    
    //MARK: LoginButtonDelegate
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        loginButton.isHidden = true
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
    }
    
    //MARK: Private Methods
    
    private func fetchProfile(){
        let parameters = ["fields": "first_name, last_name, picture.type(large)"]
        let req = GraphRequest(graphPath: "me", parameters: parameters)
        req.start{ (response, result) in
            switch result {
            case .success(let value):
                self.user.userId = AccessToken.current!.userId!
                if let first_name_value = value.dictionaryValue!["first_name"] as? String {
                    self.user.firstName = first_name_value
                }
                if let last_name_value = value.dictionaryValue!["last_name"] as? String {
                    self.user.lastName = last_name_value
                }
                if let picture = value.dictionaryValue!["picture"] as? NSDictionary,
                    let data = picture["data"] as? NSDictionary,
                    let url = data["url"] as? String{
                    self.user.profilePhoto = url
                }
                // Add user to our database if necessary
                self.refUser.observeSingleEvent(of: .value, with: { (snapshot) in
                    if (!snapshot.hasChild(AccessToken.current!.userId!)){
                        self.writeNewUser()
                    } else{
                        print("pInspire: user already exists")
                    }
                })
                DispatchQueue.main.async() {
                    [unowned self] in
                    self.performSegue(withIdentifier: "LoggingIn", sender: nil)
                }
            case .failed(let error):
                print(error)
            }
        }
    }
    
    private func writeNewUser() {
        print("pInspire: writing new user")
        // Create new user at /Users/$userId
        let key = refUser.child(AccessToken.current!.userId!)
        let newUser = ["FirstName": user.firstName,
                       "LastName": user.lastName,
                       "ProfilePhoto": user.profilePhoto] as [String : Any]
        key.setValue(newUser)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier ?? "") {
        case "LoggingIn":
            if let tabBarController = segue.destination as? UITabBarController{
                if let navigationController = tabBarController.viewControllers![0] as? UINavigationController,
                let pInspireController = navigationController.topViewController as? pInspireViewController{
                    pInspireController.user = user
                    pInspireController.userName = user.firstName + " " + user.lastName
                }
                if let navigationController = tabBarController.viewControllers![1] as? UINavigationController,
                    let contactsController = navigationController.topViewController as? ContactsTableViewController{
                    contactsController.me = user
                }
                if let navigationController = tabBarController.viewControllers![3] as? UINavigationController,
                    let discussionsController = navigationController.topViewController as? DiscussionGroupTableViewController{
                    discussionsController.me = user
                }
                // TODO: May need to set user for other tabs as well
            }
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "")")
        }
    }

}


