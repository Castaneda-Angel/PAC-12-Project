//
//  Utilities.swift
//  VOD
//
//  Created by Angel Castaneda on 2/2/23.
//

import Foundation

func secondsToMinutesString(milliseconds: Int) -> String {
    let minutes = String(milliseconds/60000)
    var seconds = String((milliseconds % 60000)/1000)
    
    if seconds.count < 2 {
        seconds = "0\(seconds)"
    }
    return "\(minutes):\(seconds)"
}

var sports: [Int:Sport] = [:]
