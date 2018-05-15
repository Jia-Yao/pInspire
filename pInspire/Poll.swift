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
    var urlString: String?
    var choices = [Choice]()
    var initiator: String = ""
    var initiatorAnonymous: Bool = false
    init(Id: String, question: String, choices: [Choice], user: String, isAnonymous: Bool, urlString: String?) {
        self.Id = Id
        self.question = question
        self.urlString = urlString
        self.choices = choices
        self.initiator = user
        self.initiatorAnonymous = isAnonymous
    }
    var numOfVotes: Int {
        return self.choices.map({$0.numOfVotes}).reduce(0, +)
    }
    
    var numOfVisibleVotedUsers: Int {
        return self.choices.map({$0.visibleUsers.count}).reduce(0, +)
    }
    
    var visibleVotedUserIds: [String] {
        return self.choices.map({$0.visibleUsers}).reduce([], +)
    }
    
    func userHasVoted(userId: String) -> Bool {
        for choice in choices {
            if choice.containUserVote(userId: userId) {
                return true
            }
        }
        return false
    }
}
