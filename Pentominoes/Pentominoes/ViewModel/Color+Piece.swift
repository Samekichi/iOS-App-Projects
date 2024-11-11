//
//  Color+Piece.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/17/23.
//

import Foundation
import SwiftUI

extension Color {
    
    init (of piece : Piece) {
        switch piece.outline.name {
        case "X":
            self = .red
        case "P":
            self = .orange
        case "F":
            self = .yellow
        case "W":
            self = .indigo
        case "Z":
            self = .mint
        case "U":
            self = .green
        case "V":
            self = .blue
        case "T":
            self = .purple
        case "L":
            self = .pink
        case "Y":
            self = .cyan
        case "N":
            self = .brown
        case "I":
            self = .gray
        default:
            self = .blue
        }
    }
}
