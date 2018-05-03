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
            return votesDict.filter{$0.value == true}.count
        }
    }
    
    func numOfVotesForUser(for user: String) -> Int {
        if invisibleUsers.contains(user) {
            return numOfVotes + 1
        } else {
            return numOfVotes
        }
    }
    
    func userHasVotedThis(user:String) -> Bool {
        return votesDict.keys.contains(user)
    }
    
    private var votesDict = [String: Bool]()
    
    var visibleUsers: [String] {
        get {
            return [String](votesDict.filter{$0.value == true}.keys)
        }
    }
    
    func containUserVote(user: String) -> Bool {
        return votesDict.keys.contains(user)
    }
    
    private var invisibleUsers: [String] {
        get {
            return [String](votesDict.filter{$0.value == false}.keys)
        }
    }
    
    func addUser(user: String, isAnonymous: Bool) {
        votesDict[user] = !isAnonymous
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

