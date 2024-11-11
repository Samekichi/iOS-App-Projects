//
//  MapKit+Constants.swift
//  Campus
//
//  Created by Andrew Wu on 10/7/23.
//

import Foundation
import MapKit
import _MapKit_SwiftUI

extension CLLocationCoordinate2D {
    static let campusCenter = CLLocationCoordinate2D(latitude: 40.80300, longitude: -77.86000)
    
    init(building : Building) {
        self = CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude)
    }
}

extension CLLocation {
    static let campusCenter = CLLocation(latitude: 40.80300, longitude: -77.86000)
}

extension MKCoordinateSpan {
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.025)
}

extension MKCoordinateRegion {
    static let campusCenterRegion = MKCoordinateRegion(center: .campusCenter, span: .defaultSpan)
}

extension MapCameraPosition {
    static let campusCenter = MapCameraPosition.region(MKCoordinateRegion.campusCenterRegion)
}
