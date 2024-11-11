//
//  CanvasColor.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/14/23.
//

import Foundation
import CoreGraphics
import CoreImage
import SwiftData


struct CanvasColor : Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    
    var cgColor: CGColor {
        CGColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    init(_ cgColor: CGColor) {
        let ciColor = CIColor(cgColor: cgColor)
        
        self.red = ciColor.red
        self.green = ciColor.green
        self.blue = ciColor.blue
        self.alpha = ciColor.alpha
    }
}
