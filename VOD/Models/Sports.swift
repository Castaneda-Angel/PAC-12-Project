//
//  Sports.swift
//  VOD
//
//  Created by Angel Castaneda on 2/3/23.
//

import Foundation

struct Sports: Codable {
    var sports: [Sport]?
}

struct Sport: Codable {
    var name: String?
    var id: Int?
    var abbr: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case id
        case abbr
    }
}
