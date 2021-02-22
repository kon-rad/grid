//
//  Path.swift
//  grid
//
//  Created by Konrad Gnat on 2/21/21.
//

import Foundation

struct Path {
    
    let name: String
    let description: String
    let geoSiteId: String
    var creatorEmail: String
    var creatorId: String
    var pathId: String
    
    init(name: String, description: String, geoSiteId: String, creatorEmail: String, creatorId: String, pathId: String) {
        self.name = name
        self.description = description
        self.geoSiteId = geoSiteId
        self.creatorEmail = creatorEmail
        self.creatorId = creatorId
        self.pathId = pathId
    }
    
}
