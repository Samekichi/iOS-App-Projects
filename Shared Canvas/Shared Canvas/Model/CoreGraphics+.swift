//
//  Color+.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/12/23.
//

import Foundation
import CoreGraphics


extension CGColor {
    static func random() -> CGColor {
        return CGColor(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1), alpha: 1)
    }
    
    static let white = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
    static let black = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
}

extension CGSize {
    // CGSize +/- CGSize
    static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func -(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
}

extension CGPoint {
    // CGPoint + CGSize
    static func +(lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
}
