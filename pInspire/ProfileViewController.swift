//
//  ProfileViewController.swift
//  pInspire
//
//  Created by Jia Yao on 5/5/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit
import FacebookLogin

class ProfileViewController: UIViewController, LoginButtonDelegate {
    
    //MARK: Properties
    
    var loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
    
    //MARK: View-related Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.center = view.center
        view.addSubview(loginButton)
        loginButton.delegate = self
    }

    //MARK: LoginButtonDelegate
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        self.performSegue(withIdentifier: "LoggingOut", sender: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
