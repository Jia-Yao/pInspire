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
    var options = [Option]()
    var initiator: User = User()
    var initiatorAnonymous: Bool = false
    init(for user: User) {
        initiator = user
    }
}
