//
//  ViewConstants.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/17/23.
//

import Foundation
import SwiftUI
import CoreGraphics

struct const {
    static let outlineWidth = CGFloat(2)
    
    static let outlineColor = Color("PrimaryColor")
    static let selectedOutlineColor = Color.white.opacity(0.75)
    static let puzzleColor = Color("SecondaryColor")
    static let shadowColor = Color("PrimaryColor").opacity(0.8)
    
    static let boardOpacity = 0.67
    static let puzzleOpacity = 0.75
    static let buttonOpacity = 0.9
    static let pieceOpacity = 1.0
    static let disableOpacity = 0.25
}
