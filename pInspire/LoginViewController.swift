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
    
    var loginButton = LoginButton(readPermissions: [ .publicProfile ])
    //var loginButton = LoginButton(readPermissions: [ .publicProfile, .userFriends ])
    var user = User(userId: "", firstName: "", lastName: "", profilePhoto: "")
    var refUser: DatabaseReference!
    var imageNameString = ["pinspire_poll", "pinspire_read", "pinspire_discuss"]
    var pictureIndex: Int = 0
    var firstLogin = false
    
    @IBOutlet weak var loginImage: UIImageView!
    //MARK: View-related Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginImage.isUserInteractionEnabled = true
        
        pictureIndex = 1
        loginImage.image = UIImage(named: "login-screen")
        
        loginButton.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height * 5 / 6)
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
            if firstLogin {
                loginImage.image = UIImage(named: "pinspire_poll")
                pictureIndex = 1
                addGestureToImage(for: loginImage)
            } else {
                // User is already logged in
                loginImage.image = UIImage(named: "login-screen")
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) {_ in
                    self.fetchProfile()
                }
            }
        }
    }
    
    //MARK: LoginButtonDelegate
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        //firstLogin = true
        if AccessToken.current != nil{
            // User is already logged in
            loginButton.isHidden = true
            // User is logged in for the first time
            self.refUser.observeSingleEvent(of: .value, with: { (snapshot) in
                if (!snapshot.hasChild(AccessToken.current!.userId!)){
                    self.firstLogin = true
                }})
            // addGestureToImage(for: loginImage)
            //z fetchProfile()
        }
    }
    
    private func addGestureToImage(for loginImage: UIImageView) {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeCard(_:)))
        swipe.direction = UISwipeGestureRecognizerDirection.left
        loginImage.addGestureRecognizer(swipe)
    }
    
    @objc func swipeCard(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            if pictureIndex == 3 {
                fetchProfile()
                pictureIndex = 1
            } else {
                loginImage.image = UIImage(named: imageNameString[pictureIndex])
                pictureIndex += 1
            }
        }
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
                // Add/update user if necessary
                self.refUser.observeSingleEvent(of: .value, with: { (snapshot) in
                    if (!snapshot.hasChild(AccessToken.current!.userId!)){
                        let key = self.refUser.child(AccessToken.current!.userId!)
                        let newUser = ["FirstName": self.user.firstName,
                                       "LastName": self.user.lastName,
                                       "ProfilePhoto": self.user.profilePhoto] as [String : Any]
                        key.setValue(newUser)
                    } else{
                        let key = self.refUser.child(AccessToken.current!.userId!).child("ProfilePhoto")
                        key.setValue(self.user.profilePhoto)
                    self.refUser.child(AccessToken.current!.userId!).child("Friends").observeSingleEvent(of: .value, with: { (snapshot) in
                        self.user.friendsDict = [String: String]()
                            if (snapshot.exists()){
                                for user in snapshot.children.allObjects as! [DataSnapshot] {
                                    self.user.friendsDict![user.key] = (user.value as! String)
                                }
                            }
                        })
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
                    contactsController.refUser = refUser
                }
                if let navigationController = tabBarController.viewControllers![2] as? UINavigationController,
                    let invitationsController = navigationController.topViewController as? InvitationsTableViewController{
                    invitationsController.me = user
                }
                if let navigationController = tabBarController.viewControllers![3] as? UINavigationController,
                    let discussionsController = navigationController.topViewController as? DiscussionGroupTableViewController{
                    discussionsController.me = user
                }
                if let profileController = tabBarController.viewControllers![4] as? ProfileViewController {
                    profileController.me = user
                }
            }
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "")")
        }
    }

}


