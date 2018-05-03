//
//  Poll.swift
//  pInspire
//
//  Created by Jia Yao on 4/28/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import Foundation
import os.log

class Poll{
    var Id: String = ""
    var question: String = ""
    var choices = [Choice]()
    var initiator: String = ""
    var initiatorAnonymous: Bool = false
    init(Id: String, question: String, choices: [Choice], user: String, isAnonymous: Bool) {
        self.Id = Id
        self.question = question
        self.choices = choices
        self.initiator = user
        self.initiatorAnonymous = isAnonymous
    }

    
    func userHasVoted(user: String) -> Bool {
        for choice in choices {
            if choice.containUserVote(user: user) {
                return true
            }
        }
        return false
    }
}
