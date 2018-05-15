//
//  User.swift
//  pInspire
//
//  Created by 臧晓雪 on 4/28/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import Foundation

class User {
    var userId: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var profilePhoto: String = ""
    var friendsDict: [String: String]?
    var userName: String {
        return firstName + " " + lastName
    }
    var visibleUserIds: [String] {
        if let friendIds = friendsDict?.keys {
            return [userId] + friendIds
        }
        return [userId]
    }
    
    var idNameConverter: [String: String] {
        if let friendsDict = friendsDict {
            return friendsDict.merging([userId: userName], uniquingKeysWith: { (_, last) in last })
        } else {
            return [userId: userName]
        }
    }
    init(userId:String, firstName:String, lastName:String, profilePhoto:String){
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.profilePhoto = profilePhoto
    }
}
