//
//  Position.swift
//  Pentominoes
//
//  Created by Hannan, John Joseph on 9/5/23.
//

import Foundation
import UIKit



// identifies placement of a single pentomino on a board, including x/y coordinate   Uses unit coordinates on a 14 x 14 board

struct Position : Equatable {
    var x : Int = 0
    var y : Int = 0
    var orientation : NumericOrientation = NumericOrientation(from: .up)
}

struct NumericOrientation : Codable, Equatable {
    var x : Int = 0
    var y : Int = 0
    var z : Int = 0
}


extension NumericOrientation {
    init(from orientation : Orientation) {
        let _o = NumericOrientation.numerifyOrientation(orientation)
        self.x = _o.x
        self.y = _o.y
        self.z = _o.z
    }
    
    static func numerifyOrientation(_ orientation : Orientation) -> NumericOrientation {
        switch orientation {
            case .up:
                return NumericOrientation(x: 0, y: 0, z: 0)
            case .down:
                return NumericOrientation(x: 0, y: 0, z: 180)
            case .left:
                return NumericOrientation(x: 0, y: 0, z: 270)
            case .right:
                return NumericOrientation(x: 0, y: 0, z: 90)
            case .upMirrored:
                return NumericOrientation(x: 0, y: 180, z: 0)
            case .downMirrored:
                return NumericOrientation(x: 0, y: 180, z: 180)
            case .leftMirrored:
                return NumericOrientation(x: 0, y: 180, z: 270)
            case .rightMirrored:
                return NumericOrientation(x: 0, y: 180, z: 90)
        }
    }
}

extension Position : Decodable {
    
    enum CodingKeys : String, CodingKey {
        case x, y, orientation
    }
    
    enum RotateDirection : Int {
        case cw = 1
        case ccw = -1
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        x = try container.decode(Int.self, forKey: .x)
        y = try container.decode(Int.self, forKey: .y)
        let _orientation = try container.decode(Orientation.self, forKey: .orientation)
        orientation = NumericOrientation.numerifyOrientation(_orientation)
    }
    
    mutating func rotateBy(_ degree: Int, direction: RotateDirection) {
        self.orientation.z = (self.orientation.z + degree * direction.rawValue)
    }
    
    mutating func flip() {
        self.orientation.y = (self.orientation.y + 180)
    }
    
    mutating func moveBy(_ translation: Size) {
        self.x += translation.width
        self.y += translation.height
    }
    
    mutating func moveTo(_ position: Position) {
        self.x = position.x
        self.y = position.y
        self.orientation = position.orientation
    }
}
