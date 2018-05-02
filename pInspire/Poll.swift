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
    var question: String = ""
    var choices = [Choice]()
    var initiator: String = ""
    var initiatorAnonymous: Bool = false
    init(question: String, choices: [Choice], user: String, isAnonymous: Bool) {
        self.question = question
        self.choices = choices
        self.initiator = user
        self.initiatorAnonymous = isAnonymous
    }
}
