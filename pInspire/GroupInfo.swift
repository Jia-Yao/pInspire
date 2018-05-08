//
//  GroupInfo.swift
//  pInspire
//
//  Created by Jia Yao on 5/7/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import Foundation

class GroupInfo {
    var groupId: String = "dummyId"
    var pollQuestion: String
    var members: [String]
    
    init(pollQuestion: String, members: [String]) {
        self.pollQuestion = pollQuestion
        self.members = members
    }
    
    func members_list() -> String{
        return members.joined(separator: ", ")
    }
}
