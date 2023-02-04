//
//  Vod.swift
//  Vod
//
//  Created by Angel Castaneda on 2/1/23.
//

import Foundation

struct Vod: Codable {
    var images: Thumbnail?
    var title: String?
    var manifest_url: String?
    var duration: Int?
    var schoolsInfo: [SchoolInfo]?
    var sportsInfo: [SportInfo]?
    
    //
    var schools: [School] = []
    var sports: [Sport] = []
    
    private enum CodingKeys: String, CodingKey {
        case images
        case title
        case manifest_url
        case duration
        case schoolsInfo = "schools"
        case sportsInfo = "sports"
    }
    
}
