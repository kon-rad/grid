//
//  Path.swift
//  grid
//
//  Created by Konrad Gnat on 2/21/21.
//

import Foundation

struct Path {
    
    var name: String
    var description: String
    let geoSiteId: String
    var creatorEmail: String
    var creatorId: String
    var pathId: String
    var documentID: String
    var worldMapDownloadURL: String
    var startImageDownloadURL: String
    var endImageDownloadURL: String
    
    init(name: String, description: String, geoSiteId: String, creatorEmail: String, creatorId: String, pathId: String, documentID: String, worldMapDownloadURL: String, startImageDownloadURL: String,
         endImageDownloadURL: String) {
        self.name = name
        self.description = description
        self.geoSiteId = geoSiteId
        self.creatorEmail = creatorEmail
        self.creatorId = creatorId
        self.pathId = pathId
        self.documentID = documentID
        self.worldMapDownloadURL = worldMapDownloadURL
        self.startImageDownloadURL = startImageDownloadURL
        self.endImageDownloadURL = endImageDownloadURL
    }
    
}
