//
//  Manager+Directions.swift
//  Campus
//
//  Created by Andrew Wu on 10/7/23.
//

import Foundation
import MapKit

extension Manager {
    func getRoute(from source : Building?, to destination : Building?) {
        let sourceItem = source != nil ? MKMapItem.forBuilding(source!) : MKMapItem.forCurrentLocation()
        let destinationItem = destination != nil ? MKMapItem.forBuilding(destination!) : MKMapItem.forCurrentLocation()
        
        getRouteBetween(sourceItem, and: destinationItem)
    }
    
    func getRoute(to destination : Building) {
        getRouteBetween(MKMapItem.forCurrentLocation(), and: MKMapItem.forBuilding(destination))
    }
    
    func getRoute(to destination : UserPickedLocationAnnotation) {
        let coordinate = destination.coordinate
        
        getRouteBetween(MKMapItem.forCurrentLocation(), and: MKMapItem.forCoordinate(coordinate))
    }
    
    // helper
    private func getRouteBetween(_ source : MKMapItem, and destination : MKMapItem) {
        // Clear previous routes
        self.clearPreviousDirection()
        self.isRouting = true
        
        // Make request
        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = .walking
        let directions = MKDirections(request: request)
        
        // Get directions
        directions.calculate{ response, error in
            guard error == nil else { print(error!); return }
            if let route = response?.routes.first {
                self.routes.append(route)
                self.eta = route.expectedTravelTime
            }
        }
    }
    func endRouting() {
        clearPreviousDirection()
        self.isRouting = false
        self.source = nil
        self.destination = nil
        self.userPickedDestination = nil
    }
    
    func clearPreviousDirection() {
        self.routes.removeAll()
        self.currentStepIndex = 0
        self.eta = 0
    }
    
}

extension MKMapItem {
    static func forBuilding(_ building : Building) -> MKMapItem {
        return MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(building: building)))
    }
    
    static func forCoordinate(_ coordinate : CLLocationCoordinate2D) -> MKMapItem {
        return MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
    }
}

extension TimeInterval {
    static func getFormattedString(of interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: interval) ?? "0 sec"
    }
}
