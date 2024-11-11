//
//  Orientation.swift
//  Pentominoes
//
//  Created by Hannan, John Joseph on 9/14/23.
//

import Foundation


// This Orientation type is identical to UIImage.Orientation.  We define it to avoid needing UIKit in the model.  See documentation for this type to see what each value means in terms of rotations and flips.  

enum Orientation : String, Codable {
    case up, left, down, right
    case upMirrored, leftMirrored, downMirrored, rightMirrored
}

