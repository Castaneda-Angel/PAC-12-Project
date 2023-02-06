//
//  Vod.swift
//  Vod
//
//  Created by Angel Castaneda on 2/1/23.
//

import Foundation

struct Programs: Codable {
    var programs: [Vod]?
    var nextPage: String?

    private enum CodingKeys: String, CodingKey {
        case programs
        case nextPage = "next_page"
    }
}

struct Vod: Codable {
    var images: Thumbnail?
    var title: String?
    var manifest_url: String?
    var duration: Int?
    var schoolsInfo: [SchoolInfo]?
    var sportsInfo: [SportInfo]?
    var created: String?
    
    // Populated after decode
    var schools: [School] = []
    var sports: [Sport] = []
    
    private enum CodingKeys: String, CodingKey {
        case images
        case title
        case manifest_url
        case duration
        case schoolsInfo = "schools"
        case sportsInfo = "sports"
        case created
    }
    
}

struct SportInfo: Codable {
    var id: Int?
}

struct SchoolInfo: Codable {
    var id: Int?
    var homeTeam: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case homeTeam = "home_team"
    }
}
