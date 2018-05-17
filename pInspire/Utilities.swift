//
//  Utilities.swift
//  pInspire
//
//  Created by 臧晓雪 on 5/16/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import Foundation

func getCurrentTime() -> String {
    let currentDateTime = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    // formatter.timeStyle = .medium
    // formatter.dateStyle = .medium
    let dateString = formatter.string(from: currentDateTime)
    
    return dateString
}
