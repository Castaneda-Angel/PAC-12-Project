//
//  Programs.swift
//  VOD
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
