//
//  Manager+Geocode.swift
//  Campus
//
//  Created by Andrew Wu on 10/7/23.
//

import Foundation
import MapKit

extension Manager {
    
    func geocodeFor(building : Building) {
        // ...
    }
    
    func geocodeFor(userPickedCoordinate : CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: userPickedCoordinate.latitude, longitude: userPickedCoordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            if let placemark = placemarks?.first {
                let mkPlacemark = MKPlacemark(placemark: placemark)
                let userPickedLocationAnnotation = UserPickedLocationAnnotation(from: mkPlacemark)
                self.userPickedLocations.append(userPickedLocationAnnotation)
                return
            }
        }
    }
    
}
