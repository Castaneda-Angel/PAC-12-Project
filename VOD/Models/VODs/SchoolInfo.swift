//
//  SchoolInfo.swift
//  VOD
//
//  Created by Angel Castaneda on 2/1/23.
//

import Foundation

struct SchoolInfo: Codable {
    var id: Int?
    var homeTeam: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case homeTeam = "home_team"
    }
}
