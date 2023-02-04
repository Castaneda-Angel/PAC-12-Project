//
//  Sport.swift
//  VOD
//
//  Created by Angel Castaneda on 2/3/23.
//

import Foundation

struct Sport: Codable {
    var name: String?
    var id: Int?
    var weight: Int?
    var abbr: String?
    var menuLabel: String?
    var hasScores: Bool?
    var inSeason: Bool?
    var isVisible: Bool?
    var url: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case id
        case weight
        case abbr
        case menuLabel = "menu_label"
        case hasScores = "has_scores"
        case inSeason = "in_season"
        case isVisible = "is_visible"
        case url
    }
}
