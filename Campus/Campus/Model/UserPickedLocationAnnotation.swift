//
//  UserPickedLocationAnnotation.swift
//  Campus
//
//  Created by Andrew Wu on 10/15/23.
//

import Foundation
import MapKit

class UserPickedLocationAnnotation : NSObject, MKAnnotation, Codable {
    let title : String?
    let subtitle : String?
    let coordinate : CLLocationCoordinate2D
    var isSelected : Bool = true
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}

extension UserPickedLocationAnnotation {
    convenience init(from placemark : MKPlacemark) {
        self.init(title: placemark.name, subtitle: placemark.locality, coordinate: placemark.coordinate)
    }
}



// Make CLLocationCoordinate2D Codable
extension CLLocationCoordinate2D : Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(latitude)
        try container.encode(longitude)
    }
    
    public init(from decoder : Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let latitude = try container.decode(CLLocationDegrees.self)
        let longitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D : Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return  lhs.latitude == rhs.latitude &&
                lhs.longitude == rhs.longitude
    }
}
