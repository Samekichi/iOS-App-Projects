//
//  MapViewCoordinator.swift
//  Campus
//
//  Created by Andrew Wu on 10/15/23.
//

import Foundation
import MapKit

class MapViewCoordinator : NSObject, MKMapViewDelegate {
    let parent : MapViewUIKit
    
    // MARK: App Manager
    let manager : Manager
    
    init(manager: Manager, parent: MapViewUIKit) {
        self.manager = manager
        self.parent = parent
    }
    
    // MARK: MapView Delegate
    /* Annotations */
    // View for
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        switch annotation {
            
        /* Building */
        case is BuildingAnnotation:
            let reuseIdentifier = "BuildingAnnotation"
            // preparation
            var annotationView : MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKMarkerAnnotationView
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            }
            let buildingAnnotation = annotation as! BuildingAnnotation
            annotationView?.annotation = buildingAnnotation
            // styling
            let tint : UIColor = buildingAnnotation.isFavorited ? UIColor.systemPink : .white
            let iconName : String = buildingAnnotation.isFavorited ? "heart.fill" : "mappin"
            annotationView?.markerTintColor = tint
            annotationView?.glyphImage = UIImage(systemName: iconName)
            // clustering
            annotationView?.clusteringIdentifier = buildingAnnotation.isFavorited ? "favoritedBuilding" : "building"
            
            return annotationView
            
        /* User-picked Location */
        case is UserPickedLocationAnnotation:
            let reuseIdentifier = "UserPickedLocationAnnotation"
            // preparation
            var annotationView : MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKMarkerAnnotationView
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            }
            let locationAnnotation = annotation as! UserPickedLocationAnnotation
            annotationView?.annotation = locationAnnotation
            // styling
            annotationView?.markerTintColor = UIColor.systemBlue
            annotationView?.glyphImage = UIImage(systemName: "bookmark.fill")
            annotationView?.canShowCallout = true
            // clustering
            annotationView?.clusteringIdentifier = "userPicked"
            // left callout
            let directionButton = UIButton(type: .custom)
            directionButton.setImage(UIImage(systemName: "arrow.triangle.turn.up.right.circle"), for: .normal)
            directionButton.tintColor = UIColor.systemBlue
            directionButton.sizeToFit()
            directionButton.tag = 0
            annotationView?.leftCalloutAccessoryView = directionButton
            // right callout
            let deleteButton = UIButton(type: .custom)
            deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
            deleteButton.tintColor = UIColor.systemRed
            deleteButton.sizeToFit()
            deleteButton.tag = 1
            annotationView?.rightCalloutAccessoryView = deleteButton
            
            return annotationView
            
        /* Clustering */
        case is MKClusterAnnotation:
            let reuseIdentifier = "ClusterAnnotationView"
            // preparation
            var annotationView : MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKMarkerAnnotationView
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            }
            annotationView!.annotation = annotation
            // get annotation category
            if let firstAnnotation = (annotation as? MKClusterAnnotation)?.memberAnnotations.first as? BuildingAnnotation {
                annotationView?.markerTintColor = firstAnnotation.isFavorited ? UIColor.systemPink : .white
                annotationView?.glyphImage = UIImage(systemName: firstAnnotation.isFavorited ? "heart.fill" : "mappin")
            } else if let _ = (annotation as? MKClusterAnnotation)?.memberAnnotations.first as? UserPickedLocationAnnotation {
                annotationView?.markerTintColor = UIColor.systemBlue
                annotationView?.glyphImage = UIImage(systemName: "bookmark.fill")
            }
            return annotationView
        /* Current User Location */
        case is MKUserLocation:
            return MKUserLocationView(annotation: annotation, reuseIdentifier: "currentUserLocation")
        default:
            return MKAnnotationView(annotation: annotation, reuseIdentifier: "defaultIdentifier")
        }
    }
        
    // Callout
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation {
            if control.tag == 0 {  // get direction to it
                manager.getRoute(to: annotation as! UserPickedLocationAnnotation)
                parent.currentSheet = .direction
                manager.userPickedDestination = annotation as? UserPickedLocationAnnotation
            } else if control.tag == 1 {  // delete annotation
                mapView.removeAnnotation(annotation)
                manager.removeUserPickedLocation(annotation as! UserPickedLocationAnnotation)
                parent.currentSheet = nil
            }
        }
    }
    
    // On Select
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            switch annotation {
            case is BuildingAnnotation:
                let annotation = annotation as! BuildingAnnotation
                parent.currentSheet = .buildingDetail(annotation.building)
            case is MKClusterAnnotation:
                let cluster = annotation as! MKClusterAnnotation
                let memberAnnotations = cluster.memberAnnotations
                // Create a region to fit all annotations in the cluster
                var displayArea = MKMapRect.null
                let rectSize = MKMapSize(width: 250, height: 125)
                for annotation in memberAnnotations {
                    let centerPoint = MKMapPoint(annotation.coordinate)
                    let centerRect = MKMapRect(origin: MKMapPoint(x: centerPoint.x - rectSize.width/2, y: centerPoint.y - rectSize.height/2), size: rectSize)
                    displayArea = displayArea.union(centerRect)
                }
                mapView.setVisibleMapRect(displayArea, animated: true)
            default:
                break
            }
        }
    }
    

    /* Overlay Renderer */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case is MKPolyline:
            let polyline = overlay as! MKPolyline
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = polyline == manager.currentStepPolyline ? UIColor(red: 102/255, green: 204/255, blue: 0/255, alpha: 1) : UIColor(red: 0/255, green: 136/255, blue: 204/255, alpha: 1)
            renderer.lineWidth = constants.routeLineWidth
            renderer.lineJoin = .round
            renderer.lineCap = .round
            return renderer
        default:
            return MKOverlayRenderer()
        }
    }
    
    
    /* Pick-location Gesture */
    @objc
    func pickLocationGestureHandler(recognizer: UILongPressGestureRecognizer) {
        let mapView = recognizer.view as! MKMapView
        
        switch recognizer.state {
        case .began:
            let point = recognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            manager.addUserPickedLocation(at: coordinate)
            recognizer.state = .cancelled
        default:
            break
        }
    }
    
    
    /* Control Visibility */
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        switch mode {
        case .follow, .followWithHeading:
            mapView.showsUserTrackingButton = false
        default:
            mapView.showsUserTrackingButton = true
        }
    }
    
}
