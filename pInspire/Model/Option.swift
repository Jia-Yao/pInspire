//
//  Option.swift
//  pInspire
//
//  Created by 臧晓雪 on 4/28/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import Foundation

class Option {
    var content: String = ""
    var numOfVotes: Int = 0
    var visibleUsers = [User]()
    private var invisibleUsers = [User]()
    init(for option: String){
        content = option
    }
}

