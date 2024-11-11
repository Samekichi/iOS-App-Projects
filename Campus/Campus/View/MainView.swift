//
//  SwiftUIMapView.swift
//  Campus
//
//  Created by Andrew Wu on 10/1/23.
//

import SwiftUI
import MapKit


enum MapKind {
    case UIKit, SwiftUI
}

enum MapConfig {
    case standard, hybrid, imagery
    
    var config : MKMapConfiguration {
        switch self {
        case .standard:
            return MKStandardMapConfiguration()
        case .hybrid:
            return MKHybridMapConfiguration()
        case .imagery:
            return MKImageryMapConfiguration()
        }
    }
}


struct MainView : View {
    @Environment(Manager.self) private var manager
    @State private var position : MapCameraPosition = .campusCenter
    @State private var currentSheet : SheetContent?
    @State private var selectedBuilding : Building?
    @State private var mapKind : MapKind = .UIKit
    @State private var configuration : MapConfig = .standard
    
    var body: some View {
        
        mapViewOf(mapKind)
            .padding(.top)
            .onChange(of: selectedBuilding) {
                if let building = selectedBuilding {
                    currentSheet = .buildingDetail(building)
                }
            }
            .onChange(of: manager.selectedBuildings.count) {  // don't change on (un)favorite
                manager.selectedBuildings.count == 0 ?
                    withAnimation(.easeInOut(duration: 2)) {
                        position = .userLocation(fallback: .campusCenter)
                    } 
                    :
                    withAnimation(.easeInOut(duration: 2)) {
                        position = .automatic
                    }
            }
            .onChange(of: manager.routes) {
                withAnimation(.easeInOut(duration: 2)) {
                    position = manager.routes.count == 0 ? .userLocation(fallback: .campusCenter) : .automatic
                }
            }
            .onChange(of: manager.currentStepIndex) {
                withAnimation(.easeInOut(duration: 1)) {
                    position = manager.source == nil || manager.destination == nil ? .userLocation(fallback: .campusCenter) : .automatic
                }
            }
            .sheet(item: $currentSheet, onDismiss: {
                selectedBuilding = nil
            }) { sheet in
                switch sheet {
                case .buildingDetail(let building):
                    BuildingDetailView(currentSheet: $currentSheet, building: building)
                        .presentationDetents(sheet.detents)
                case .buildingsList:
                    BuildingsListView()
                        .presentationDetents(sheet.detents)
                case .directionRequest:
                    DirectionRequestView(currentSheet: $currentSheet)
                        .presentationDetents(sheet.detents)
                case .direction:
                    DirectionView()
                        .presentationDetents(sheet.detents)
                        .presentationBackgroundInteraction(.enabled)
                }
            }
            // Top controls
            .safeAreaInset(edge: .top) {
                MapTopControlView(currentSheet: $currentSheet)
                .padding([.leading, .top, .trailing])
            }
            // Switch SwiftUI / UIKit & Select Map Configuration
            .safeAreaInset(edge: .bottom) {
                MapCornerControlView(mapKind: $mapKind, configuration: $configuration)
                .padding(.bottom, 15) 
            }
    }
}

#Preview {
    MainView()
        .environment(Manager())
}


extension MainView {
    
    @ViewBuilder
    private func mapViewOf(_ mapKind: MapKind) -> some View {
        
        switch mapKind {
        case .SwiftUI:
            Map(position: $position, selection: $selectedBuilding) {
                // buildings
                selectedBuildings
                // user related
                routes
                currentStep
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
            }
            .mapControlVisibility(
                position.followsUserLocation ? .hidden : .visible
            )
        case .UIKit:
            MapViewUIKit(selection: $selectedBuilding, currentSheet: $currentSheet, configuration: $configuration)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    
    var buildings : some MapContent {
        ForEach(manager.buildings) { building in
            Marker(building.name, systemImage: building.isFavorited ? "heart.fill" : "mappin", coordinate: .init(building: building)).tag(building)
                .tint(building.isFavorited ? .pink : .white)
        }
    }
    
    var selectedBuildings : some MapContent {
        ForEach(manager.selectedBuildings) { building in
            Marker(building.name, systemImage: building.isFavorited ? "heart.fill" : "mappin", coordinate: .init(building: building)).tag(building)
                .tint(building.isFavorited ? .pink : .white)
        }
    }
    
    var routes : some MapContent {
        ForEach(manager.routes, id: \.self) { route in
            Group{
                MapPolyline(route.polyline)
                    .stroke(constants.routeColor, style: constants.routeStyle)
            }
        }
    }
    
    var currentStep : some MapContent {
        MapPolyline(manager.currentStepPolyline)
            .stroke(constants.currentStepColor, style: constants.routeStyle)
    }
        
}


enum SheetContent : Identifiable, Hashable {
    case buildingDetail(Building)
    case buildingsList
    case directionRequest
    case direction
    // ...
    
    var id : Self  { self }
    var detents : Set<PresentationDetent>  {
        switch self {
        case .buildingDetail(let building):
            if building.hasPhoto() {
                return [PresentationDetent.fraction(0.33), PresentationDetent.fraction(0.6)]
            } else {
                return [PresentationDetent.fraction(0.33)]
            }
        case .buildingsList:
            return [PresentationDetent.fraction(0.8)]
        case .directionRequest:
            return [PresentationDetent.fraction(0.2), PresentationDetent.fraction(0.6)]
        case .direction:
            return [PresentationDetent.fraction(0.2), PresentationDetent.fraction(0.6)]
        }
        
    }
}
