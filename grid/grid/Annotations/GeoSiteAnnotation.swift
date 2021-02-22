//
//  GeoSiteAnnotation.swift
//  grid
//
//  Created by Konrad Gnat on 2/21/21.
//

import MapKit

class GeoSiteAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var name: String
    var createdByUser: String
    var geoSiteId: String
    var creatorId: String
    
    
    var title: String? {
        if name.isEmpty {
        return "Name is Empty"
      }
      return name
    }
    
    var subtitle: String? {
        if createdByUser.isEmpty {
          return "Created By is Empty"
        }
        return createdByUser
    }
    
    init(coordinate: CLLocationCoordinate2D, name: String, createdByUser: String, geoSiteId: String, creatorId: String) {
        self.coordinate = coordinate
        self.name = name
        self.createdByUser = createdByUser
        self.geoSiteId = geoSiteId
        self.creatorId = creatorId
    }
}
