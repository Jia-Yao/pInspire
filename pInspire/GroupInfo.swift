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
    var memberIds: [String]
    var hasSeen: Bool
    
    init(pollQuestion: String, members: [String], memberIds: [String], hasSeen: Bool) {
        self.pollQuestion = pollQuestion
        self.members = members
        self.memberIds = memberIds
        self.hasSeen = hasSeen
    }
    
    convenience init(pollQuestion: String, members: [String], memberIds: [String], groupId: String, hasSeen: Bool) {
        self.init(pollQuestion: pollQuestion, members: members, memberIds: memberIds, hasSeen: hasSeen)
        self.groupId = groupId
    }
    
    func members_list() -> String{
        return members.joined(separator: ", ")
    }
}
