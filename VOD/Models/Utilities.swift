//
//  Utilities.swift
//  VOD
//
//  Created by Angel Castaneda on 2/2/23.
//

import Foundation

func getDurationString(from milliseconds: Int) -> String {
    var minutes = String(milliseconds/60000)
    var seconds = String((milliseconds % 60000)/1000)
    
    if minutes.count < 2 {
        minutes = "0\(minutes)"
    }
    if seconds.count < 2 {
        seconds = "0\(seconds)"
    }
    return "\(minutes):\(seconds)"
}

func getDaysAgoString(from stringDate: String) -> String {
    let dateFormatter = ISO8601DateFormatter()
    
    //Turns string date to Date type, need to follow ISO8601 so we need the above dateFormatter for this
    let date = dateFormatter.date(from: stringDate)
    
    //New formatter to get generic date (fixes timezone issue)
    let genericDateFormatter = DateFormatter()
    genericDateFormatter.timeZone = TimeZone.current
    genericDateFormatter.dateFormat = "yyyy-MM-dd"
    
    if let createdDate = date {
        // Turns the ISO date back to a string following the genericDateFormatter format
        let createdDateString = genericDateFormatter.string(from: createdDate)
        
        // Turns the generic date string back into a Date (we need 2 Dates to get the difference between them)
        if let updatedDate = genericDateFormatter.date(from: createdDateString), let dayDiff = Calendar.current.dateComponents([.day], from: Date(), to: updatedDate).day {
            
            // dayDiff is negative, abs() is necessary
            if abs(dayDiff) == 0 {
                return "Today"
            } else if abs(dayDiff) == 1 {
                return "Yesterday"
            } else {
                return "\(abs(dayDiff)) days ago"
            }
        } else {
            return ""
        }
    } else {
        return ""
    }
}
