//
//  Invitation.swift
//  pInspire
//
//  Created by 臧晓雪 on 5/14/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import Foundation
class Invitation {
    var textMessage: String = ""
    var hasSeen: Bool = false
    var senderId: String = ""
    var invitationId: String = ""
    
    init(text: String, hasSeen: Bool, senderId: String, invitationId: String) {
        self.textMessage = text
        self.hasSeen = hasSeen
        self.senderId = senderId
        self.invitationId = invitationId
    }
}
