//
//  User.swift
//  pInspire
//
//  Created by 臧晓雪 on 4/28/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import Foundation

class User {
    var email: String = ""
    var userName: String = ""
    var password: String = ""
    var initiatedPolls = [Poll]()
    var participatedPolls = [Poll]()
}
