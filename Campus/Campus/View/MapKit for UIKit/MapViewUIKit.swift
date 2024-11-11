//
//  MapViewUIKit.swift
//  Campus
//
//  Created by Andrew Wu on 10/15/23.
//

import SwiftUI
import MapKit

struct MapViewUIKit: UIViewRepresentable {
    @Environment(Manager.self) var manager
    @Binding var selection : Building?
    @Binding var currentSheet : SheetContent?
    @Binding var configuration : MapConfig
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        // Map parameters
        mapView.region = .campusCenterRegion
        mapView.showsUserLocation = true
        mapView.showsUserTrackingButton = true
        mapView.delegate = context.coordinator
        mapView.preferredConfiguration = configuration.config
        // Markers
        mapView.showAnnotations(manager.annotationsToDisplay, animated: true)
        // Clustering
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        // Gestures
        let pickLocationGesture = UILongPressGestureRecognizer(target: mapView.delegate, action: #selector(MapViewCoordinator.pickLocationGestureHandler(recognizer:)))
        mapView.addGestureRecognizer(pickLocationGesture)
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Annotations & Display Region
        mapView.removeAnnotations(mapView.annotations)
        var annotationsToDisplay : [MKAnnotation] = manager.annotationsToDisplay
        if mapView.userLocation.coordinate != CLLocationCoordinate2D() { annotationsToDisplay.append(mapView.userLocation) }
        mapView.showAnnotations(annotationsToDisplay, animated: true)
        // Overlays
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(manager.currentStepPolyline)
        mapView.addOverlays(manager.steps.map { $0.polyline })
        // Map Type
        mapView.preferredConfiguration = configuration.config
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(manager: manager, parent: self)
    }
}

#Preview {
    MapViewUIKit(selection: .constant(nil), currentSheet: .constant(nil), configuration: .constant(.hybrid))
        .environment(Manager())
}
