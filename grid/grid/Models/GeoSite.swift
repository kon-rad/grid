//
//  GeoSite.swift
//  grid
//
//  Created by Konrad Gnat on 2/6/21.
//

import Foundation
import Firebase

struct GeoSite {
    let name: String
    let geohash: String
    let lat: String
    let lon: String
    let id: String
    let createByUser: String
    
    init(name: String, geohash: String, lat: String, lon: String, id: String, createdByUser: String) {
        self.name = name
        self.geohash = geohash
        self.lat = lat
        self.lon = lon
        self.id = id
        self.createByUser = createdByUser
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "geohash": geohash,
            "lat": lat,
            "lon": lon,
            "id": id,
            "createByUser": createByUser,
        ]
    }
}
