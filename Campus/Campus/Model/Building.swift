//
//  Building.swift
//  Campus
//
//  Created by Andrew Wu on 10/1/23.
//

import Foundation
import MapKit

struct Building : Identifiable, Hashable {
    // Asset fields
    let latitude : CLLocationDegrees
    let longitude : CLLocationDegrees
    let name : String
    let opp_bldg_code : Int
    let year_constructed : Int?
    let photo : String?
    var coordinate : CLLocationCoordinate2D  {CLLocationCoordinate2D(latitude: latitude, longitude: longitude)}
    // App persist fields
    var isFavorited : Bool = false
    var isSelected : Bool = true
    // Identifiable
    var id = UUID()
}


extension Building {
    
    mutating func deselect() {
        self.isSelected = false
    }
    
    mutating func select() {
        self.isSelected = true
    }
    
    // Get building details
    func getName() -> String {
        return self.name
    }

    func getYearOfConstruction() -> String {
        return self.year_constructed != nil ? String(format: "%d", self.year_constructed!) : ""
    }

    func getPhoto() -> String {
        return self.photo ?? "placeholder"
    }
    
    func hasPhoto() -> Bool {
        return self.photo != nil
    }
    
    // Const for preview
    static let constant = Building(latitude: 40.808615773028, longitude: -77.8555409099202, name: "Bryce Jordan Center", opp_bldg_code: 45000, year_constructed: 1955, photo: "brycejordan")
}

extension Building : Equatable {
    static func == (lhs: Building, rhs: Building) -> Bool {
        return  lhs.name == rhs.name &&
                lhs.opp_bldg_code == rhs.opp_bldg_code &&
                lhs.latitude == rhs.latitude &&
                lhs.longitude == rhs.longitude
    }
}


extension Building : Codable {
    // Support decoding from default asset with fewer fields
    enum CodingKeys : String, CodingKey {
        case latitude, longitude, name, opp_bldg_code  // must exist
        case year_constructed, photo, isFavorited, isSelected, id  // may exist
    }
    
    init(from decoder : Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // must have
        latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        name = try container.decode(String.self, forKey: .name)
        opp_bldg_code = try container.decode(Int.self, forKey: .opp_bldg_code)
        // may have
        year_constructed = try container.decodeIfPresent(Int.self, forKey: .year_constructed)
        photo = try container.decodeIfPresent(String.self, forKey: .photo)
        isFavorited = try container.decodeIfPresent(Bool.self, forKey: .isFavorited) ?? false
        isSelected = try container.decodeIfPresent(Bool.self, forKey: .isSelected) ?? true
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
    }
}
