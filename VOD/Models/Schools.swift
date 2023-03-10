//
//  Schools.swift
//  VOD
//
//  Created by Angel Castaneda on 2/3/23.
//

import Foundation
import UIKit

struct Schools: Codable {
    var schools: [School]?
}

struct School: Codable {
    var id: Int?
    var name: String?
    var images: Thumbnail?
    
    // Populated after decode
    var imageData: Data?
}
