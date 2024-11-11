//
//  Manager.swift
//  Campus
//
//  Created by Andrew Wu on 10/1/23.
//

import Foundation
import MapKit
import Observation


@Observable
class Manager : NSObject {
    /* Persistence */
    private let buildingsPersistence : Persistence<[Building]>
    private let userPickedLocationsPersistence : Persistence<[UserPickedLocationAnnotation]>
    /* Model */
    // Buildings & User Picked Locations
    var buildings : [Building]
    var userPickedLocations : [UserPickedLocationAnnotation]
    // Filtered buildings
    var selectedBuildings : [Building]  { buildings.filter{ $0.isSelected } }
    var favoritedBuildings : [Building]  { buildings.filter{ $0.isFavorited } }
    var unfavoritedBuildings : [Building]  { buildings.filter{ !$0.isFavorited } }
    var hiddenPositioningBuildings : [Building]  { buildings.filter{ ["Ikenberry Hall", "Ferguson Hall", "Central Milk Testing Lab", "Swine Research"].contains($0.name) } }
    
    /* View Model */
    // CLLocationManager
    let locationManager : CLLocationManager
    let nearbyThreshold : CLLocationDistance = 500
    // Model States
    var hasFavorite : Bool  { buildings.contains{ $0.isFavorited } }
    var hasRoutes : Bool  { routes.count != 0 }
    
    var isShowingAllFavorite : Bool  {
        hasFavorite &&
        buildings.allSatisfy{
            !$0.isFavorited ||
            $0.isFavorited && $0.isSelected
        }
    }
    var isDeselectingAll : Bool  { buildings.allSatisfy { !$0.isSelected} }
    var isShowingAllPickedLocarions : Bool  { userPickedLocations.allSatisfy{ $0.isSelected } }
    var isRouting : Bool = false
   
    /* View */
    // Direction Request
    var currentUserLocation : CLLocation = .campusCenter
    
    var source : Building?
    var destination : Building?
    var sourceIndex : Int?  {
        if let source = source {
            return getBuildingIndex(source)
        } else { return nil } }
    var destinationIndex : Int?  {
        if let destination = destination {
            return getBuildingIndex(destination)
        } else { return nil } }
    var userPickedDestination : UserPickedLocationAnnotation?
    
    var sourceAnnotation : BuildingAnnotation?  {
        if let sourceIndex = sourceIndex {
            return BuildingAnnotation(from: buildings[sourceIndex])
        } else { return nil }
    }
    var destinationAnnotation : MKAnnotation? {
        if let destinationIndex = destinationIndex {
            return BuildingAnnotation(from: buildings[destinationIndex])
        } else if let userPickedDestination = userPickedDestination {
            return userPickedDestination
        } else { return nil }
    }
    // Routes
    var routes = [MKRoute]()
    var steps : [MKRoute.Step] { routes.last?.steps ?? [] }
    var currentStepIndex : Int = 0
    var currentStepPolyline : MKPolyline  {
        if self.currentStepIndex < self.steps.count {
            return self.steps[currentStepIndex].polyline
        } else {
            return MKPolyline(coordinates: [], count: 0)
        }
    }
    var eta : TimeInterval = 0
    // Annotations
    var annotationsToDisplay : [MKAnnotation]  {
        isRouting ?
        routingAnnotations :
        selectedBuildingsAnnotations + userPickedLocations }
    
    var routingAnnotations : [MKAnnotation]  {
        var annotations = [MKAnnotation]()
        if let sourceAnnotation = sourceAnnotation {
            annotations.append(sourceAnnotation)
        }
        if let destinationAnnotation = destinationAnnotation {
            annotations.append(destinationAnnotation)
        }
        return annotations
    }
    var selectedBuildingsAnnotations : [BuildingAnnotation]  { selectedBuildings.map { BuildingAnnotation(from: $0)} }
   
    /* init */
    override init() {
        /* App Manager */
        // buildings
        self.buildingsPersistence = Persistence(fileName: "buildings_status")
        if let buildings = buildingsPersistence.items {
            self.buildings = buildings.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending})
        } else {
            self.buildings = []
        }
        // user picked locations
        self.userPickedLocationsPersistence = Persistence(fileName: "user_picked_locations", defaultItems: [UserPickedLocationAnnotation]())
        self.userPickedLocations = userPickedLocationsPersistence.items!
        /* CLLocationManager */
        locationManager = CLLocationManager()
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
}


extension Manager {
    
    // Persistence
    func save() {
        buildingsPersistence.save(buildings)
        userPickedLocationsPersistence.save(userPickedLocations)
    }
    
    // Buildings details
    func getBuildings(by filter : BuildingFilter) -> [Building] {
        switch filter {
        case .all:
            return self.buildings
        case .favorited:
            return self.favoritedBuildings
        case .selected:
            return self.selectedBuildings
        case .nearby:
            return self.getNearbyBuildings()
        }
    }
    
    func getNearbyBuildings() -> [Building] {
        return self.buildings.filter { isBuildingNearby($0) }
    }
    
    func isBuildingNearby(_ building : Building) -> Bool {
        let buildingLocation = CLLocation(latitude: building.latitude, longitude: building.longitude)
        let distance = self.currentUserLocation.distance(from: buildingLocation)
        return distance <= self.nearbyThreshold
    }
    
    func getBuildingIndex(_ building: Building) -> Int? {
        return buildings.firstIndex(where: { $0 == building })
    }
    
    func isBuildingFavorited(_ building : Building) -> Bool {
        if let index = getBuildingIndex(building) {
            return buildings[index].isFavorited
        }
        return false
    }
    
    func isBuildingSelected(_ building : Building) -> Bool {
        if let index = getBuildingIndex(building) {
            return buildings[index].isSelected
        }
        return false
    }
    
    // Modify buildings
    func toggleFavorite(of building : Building) {
        if let index = getBuildingIndex(building) {
            buildings[index].isFavorited.toggle()
        }
    }
    
    func toggleSelection(of building : Building) {
        if let index = getBuildingIndex(building) {
            buildings[index].isSelected.toggle()
        }
    }
    
    func toggleAllFavorite(to isSelected : Bool? = nil ) {
        let isSelected = isSelected ?? !isShowingAllFavorite
        for i in 0..<buildings.count {
            if buildings[i].isFavorited {
                buildings[i].isSelected = isSelected
            }
        }
    }
    
    func toggleAllSelection(to isSelected : Bool? = nil) {
        let isSelected = isSelected ?? isDeselectingAll
        for i in 0..<buildings.count {
            buildings[i].isSelected = isSelected
        }
    }
    
    func toggleAllOf(_ buildings : [Building], to isSelected : Bool) {
        buildings.forEach { building in
            if let index = getBuildingIndex(building) {
                self.buildings[index].isSelected = isSelected
            }
        }
    }
    
    // Modify User Picked Locations
    func addUserPickedLocation(at coordinate: CLLocationCoordinate2D) {
        geocodeFor(userPickedCoordinate: coordinate)
    }
    
    func removeUserPickedLocation(_ annotation : UserPickedLocationAnnotation) {
        let coordinate = annotation.coordinate
        if let index = userPickedLocations.firstIndex(where: { $0.coordinate == coordinate }) {
            userPickedLocations.remove(at: index)
        }
        if userPickedDestination?.coordinate == coordinate {
            userPickedDestination = nil
            endRouting()
        }
    }
    
    func toggleSelection(of userPickedLocation : UserPickedLocationAnnotation, to isSelected : Bool) {
        if let index = userPickedLocations.firstIndex(of: userPickedLocation) {
            userPickedLocations[index].isSelected = isSelected
        }
    }
    
    func toggleAllPickedLocationsSelection(to isSelected : Bool? = nil) {
        let isSelected = isSelected ?? !isShowingAllPickedLocarions
        for i in 0..<userPickedLocations.count {
            userPickedLocations[i].isSelected = isSelected
        }
    }
}

