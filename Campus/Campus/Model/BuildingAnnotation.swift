//
//  BuildingAnnotation.swift
//  Campus
//
//  Created by Andrew Wu on 10/15/23.
//

import Foundation
import MapKit

class BuildingAnnotation : NSObject, MKAnnotation {
    let title : String?
    let subtitle : String?
    let coordinate : CLLocationCoordinate2D
    let isFavorited : Bool
    let building : Building
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, isFavorited: Bool, building: Building) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.isFavorited = isFavorited
        self.building = building
    }
}

extension BuildingAnnotation {
    convenience init(from building: Building) {
        self.init(title: building.name, subtitle: nil, coordinate: building.coordinate, isFavorited: building.isFavorited, building: building)
    }
}
