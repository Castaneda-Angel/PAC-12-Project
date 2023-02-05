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

func dateToDaysAgoString(_ stringDate: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    let date = dateFormatter.date(from: stringDate)
    
    let calendar = Calendar.current
    
    let createdDateComponents = calendar.dateComponents([.day, .month, .year], from: date!)
    let createdDate = calendar.date(from: createdDateComponents)
    
    //let dayDiff = calendar.dateComponents([.day], from: today, to: createdDay)
    let dayDiff = calendar.dateComponents([.day], from: Date(), to: createdDate!).day
    if abs(dayDiff!) == 0 {
        return "Today"
    } else if abs(dayDiff!) == 1 {
        return "Yesterday"
    } else {
        return "\(abs(dayDiff!)) days ago"
    }
}

var sports: [Int:Sport] = [:]
