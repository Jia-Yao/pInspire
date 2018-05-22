//
//  Option.swift
//  pInspire
//
//  Created by 臧晓雪 on 4/28/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import Foundation

class Choice {
    var content: String = ""
    
    var numOfVotes: Int {
        get {
            // exclude dummy user.
            return votesDict.count // votesDict.filter{$0.value == true}.count
        }
    }
    
    func numOfVotesForMe(for user: String) -> Int {
        return numOfVotes
    }
    /* func numOfVotesForMe(for user: String) -> Int {
        if invisibleUsers.contains(user) {
            return numOfVotes + 1
        } else {
            return numOfVotes
        }
    }*/
    
    func userHasVotedThis(userId: String) -> Bool {
        return votesDict.keys.contains(userId)
    }
    
    private var votesDict = [String: Bool]()
    
    var visibleUsers: [String] {
        get {
            return [String](votesDict.filter{$0.value == true}.keys)
        }
    }
    
    func visibleUsersForMe(userId: String) -> [String] {
        if invisibleUsers.contains(userId) {
            return visibleUsers + [userId]
        } else {
            return visibleUsers
        }
    }
    
    func containUserVote(userId: String) -> Bool {
        return votesDict.keys.contains(userId)
    }
    
    // Note: this invisibleUsers include one "dummy" user.
    private var invisibleUsers: [String] {
        get {
            return [String](votesDict.filter{$0.value == false}.keys)
        }
    }
    
    func invisibleUsersForMe(userId: String) -> [String] {
        return invisibleUsers.filter { $0 != "dummy" }.filter { $0 != userId }.map { _ in "0" }
    }
    
    func totalUsersForMe(userId: String) -> [String] {
        return visibleUsersForMe(userId: userId) + invisibleUsersForMe(userId: userId)
    }
    
    func addUser(userId: String, isAnonymous: Bool) {
        votesDict[userId] = !isAnonymous
    }
    
    convenience init(for choice: String, votes: Dictionary<String, Bool>){
        self.init()
        self.content = choice
        self.votesDict = votes
    }
    /*
    convenience init(for choice: String, votes: Dictionary<String, Int>){
        self.init()
        self.content = choice
        for key in votes.keys {
            self.votesDict[key] = Bool(truncating: votes[key]! as NSNumber)
        }
    }*/
}

