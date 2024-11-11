//
//  CanvasElements.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/12/23.
//

import Foundation
import SwiftUI
import UIKit
import SwiftData

/* MARK: Stroke */
struct CanvasStroke : CanvasElement, Codable {
    
    var id = UUID()
    
    var toolType : ToolType = ToolType.pencil
    var canvasColor : CanvasColor
    var linewidth : Double
    
    // fields
    var points : [CGPoint]
    
    var color : Color  { Color(canvasColor.cgColor)}
    
    init(cgColor: CGColor, linewidth: CGFloat, willErase: Bool, points: [CGPoint]) {
        self.canvasColor = CanvasColor(cgColor)
        self.linewidth = linewidth
        self.points = points
    }
    
    func contains(point: CGPoint, threshold: Double = 1) -> Bool {
        for strokePoint in points {
            let distance = hypot(strokePoint.x - point.x, strokePoint.y - point.y)
            if distance < threshold {
                return true
            }
        }
        return false
    }
    
    func render() -> AnyView {
        AnyView(
            path()
                .stroke(color, lineWidth: linewidth)
        )
    }
    
    func path() -> Path {
        Path { path in
//            if let firstPoint = points.first {
//                path.move(to: firstPoint)
//                for point in points.dropFirst() {
//                    path.addLine(to: point)
//                }
//            }
            if let firstPoint = points.first {
                path.move(to: firstPoint)
                for i in points.indices.dropLast() {
                    let currentPoint = points[i]
                    let nextPoint = points[i + 1]
                    let midPoint = CGPoint(x: (currentPoint.x + nextPoint.x) / 2,
                                           y: (currentPoint.y + nextPoint.y) / 2 )

                    path.addQuadCurve(to: midPoint, control: currentPoint)
    //                path.addQuadCurve(to: nextPoint, control: midPoint)
                }
            }
        }
    }
    
    mutating func move(by offset: CGSize) {
        self.points = points.map { $0 + offset }
    }
}


/* MARK: Shapes */
struct CanvasTriangle: CanvasElement, CanvasShape, Codable {
    
    var id = UUID()
    
    var toolType : ToolType = ToolType.shape(.triangle)
    var canvasColor : CanvasColor
    var linewidth : Double
    // fields
    var start : CGPoint
    var end : CGPoint
    var isFilled : Bool
    var shapeType : ShapeType = ShapeType.triangle
    
    var color : Color  { Color(canvasColor.cgColor)}
    
    init(cgColor: CGColor, linewidth: CGFloat, willErase: Bool, start: CGPoint, end: CGPoint, isFilled: Bool) {
        self.canvasColor = CanvasColor(cgColor)
        self.linewidth = linewidth
        self.start = start
        self.end = end
        self.isFilled = isFilled
    }
    
    func contains(point: CGPoint, threshold: Double = 1) -> Bool {
        var topVertex: CGPoint = CGPoint(x: (start.x + end.x) / 2, y: start.y)
        var leftPoint: CGPoint = CGPoint(x: start.x, y: end.y)
        var rightPoint: CGPoint = CGPoint(x: end.x, y: end.y)
        let expansion : Double = 5
        
        let center = CGPoint(x: (topVertex.x + leftPoint.x + rightPoint.x) / 3,
                             y: (topVertex.y + leftPoint.y + rightPoint.y) / 3)

        // expand detection area
        topVertex = expandPoint(point: topVertex, center: center, expansion: expansion)
        leftPoint = expandPoint(point: leftPoint, center: center, expansion: expansion)
        rightPoint = expandPoint(point: rightPoint, center: center, expansion: expansion)
        
        let v0 = CGPoint(x: rightPoint.x - leftPoint.x, y: rightPoint.y - leftPoint.y)
        let v1 = CGPoint(x: topVertex.x - leftPoint.x, y: topVertex.y - leftPoint.y)
        let v2 = CGPoint(x: point.x - leftPoint.x, y: point.y - leftPoint.y)

        let dot00 = v0.x * v0.x + v0.y * v0.y
        let dot01 = v0.x * v1.x + v0.y * v1.y
        let dot02 = v0.x * v2.x + v0.y * v2.y
        let dot11 = v1.x * v1.x + v1.y * v1.y
        let dot12 = v1.x * v2.x + v1.y * v2.y

        let invCoeff = 1 / (dot00 * dot11 - dot01 * dot01)
        let u = (dot11 * dot02 - dot01 * dot12) * invCoeff
        let v = (dot00 * dot12 - dot01 * dot02) * invCoeff

        return (u >= 0) && (v >= 0) && (u + v <= 1)
    }
    
    // helper of contains() to move vertices outwards by a certian amount
    private func expandPoint(point: CGPoint, center: CGPoint, expansion: Double) -> CGPoint {
        let direction = CGPoint(x: point.x - center.x, y: point.y - center.y)
        let length = sqrt(direction.x * direction.x + direction.y * direction.y)
        let normalizedDirection = CGPoint(x: direction.x / length, y: direction.y / length)
        return CGPoint(x: point.x + normalizedDirection.x * expansion, y: point.y + normalizedDirection.y * expansion)
    }
    
    func render() -> AnyView {
        AnyView(
            path()
                .stroke(color, lineWidth: isFilled ? 0 : linewidth)
                .fill(isFilled ? color : Color.clear)
        )
    }
    
    func path() -> Path {
        Path { path in
            let middle = CGPoint(x: (start.x + end.x) / 2, y: start.y)
            path.move(to: middle)
            path.addLine(to: CGPoint(x: end.x, y: end.y))
            path.addLine(to: CGPoint(x: start.x, y: end.y))
            path.closeSubpath()
        }
    }
    
    mutating func move(by offset: CGSize) {
        self.start = start + offset
        self.end = end + offset
    }
}

//@Model
struct CanvasRectangle: CanvasElement, CanvasShape, Codable {
    
    var id = UUID()
    
    var toolType : ToolType = ToolType.shape(.rectangle)
    var canvasColor : CanvasColor
    var linewidth : Double
    
    // fields
    var start : CGPoint
    var end : CGPoint
    var isFilled : Bool
    var shapeType : ShapeType = ShapeType.triangle
    
    var color : Color  { Color(canvasColor.cgColor) }
    var rect : CGRect {
        CGRect(x: min(start.x, end.x), y: min(start.y, end.y), width: abs(end.x - start.x), height: abs(end.y - start.y))
    }
    
    init(cgColor: CGColor, linewidth: CGFloat, willErase: Bool, start: CGPoint, end: CGPoint, isFilled: Bool) {
        self.canvasColor = CanvasColor(cgColor)
        self.linewidth = linewidth
        self.start = start
        self.end = end
        self.isFilled = isFilled
    }
    
    func contains(point: CGPoint, threshold: Double = 1 ) -> Bool {
        let expansion : Double = 5
        return CGRect(x: min(start.x, end.x) - expansion/2, y: min(start.y, end.y) - expansion/2, width: abs(end.x - start.x) + expansion, height: abs(end.y - start.y) + expansion).contains(point)
    }
    
    func render() -> AnyView {
        AnyView(
            path()
                .stroke(color, lineWidth: isFilled ? 0 : linewidth)
                .fill(isFilled ? color : Color.clear)
        )
    }
    
    func path() -> Path {
        Path { path in
            path.addRect(rect)
        }
    }
    
    mutating func move(by offset: CGSize) {
        self.start = start + offset
        self.end = end + offset
    }
}

//@Model
struct CanvasCircle: CanvasElement, CanvasShape, Codable {
    
    var id = UUID()
    
    var toolType : ToolType = ToolType.shape(.circle)
    var canvasColor : CanvasColor
    var linewidth : Double
    
    // fields
    var start : CGPoint
    var end : CGPoint
    var isFilled : Bool
    var shapeType : ShapeType = ShapeType.triangle
    
    var color : Color  { Color(canvasColor.cgColor) }
    var center : CGPoint  {
        CGPoint(
            x: (start.x + end.x) / 2,
            y: (start.y + end.y) / 2
        )
    }
    
    init(cgColor: CGColor, linewidth: CGFloat, willErase: Bool, start: CGPoint, end: CGPoint, isFilled: Bool) {
        self.canvasColor = CanvasColor(cgColor)
        self.linewidth = linewidth
        self.start = start
        self.end = end
        self.isFilled = isFilled
    }
    
    func contains(point: CGPoint, threshold: Double = 1) -> Bool {
        let expansion : Double = 5
        let r_x : Double = (abs(end.x - start.x) + expansion) / 2
        let r_y : Double = (abs(end.y - start.y) + expansion) / 2
        let dx : Double = abs(center.x - point.x)
        let dy : Double = abs(center.y - point.y)
        let distance : Double = pow(dx, 2) / pow(r_x, 2) + pow(dy, 2) / pow(r_y, 2)
        return distance <= 1
    }
    
    func render() -> AnyView {
        AnyView(
            path()
                .stroke(color, lineWidth: isFilled ? 0 : linewidth)
                .fill(isFilled ? color : Color.clear)
        )
    }
    
    func path() -> Path {
        Path { path in
            let rect = CGRect(
                x: min(start.x, end.x),
                y: min(start.y, end.y),
                width: abs(end.x - start.x),
                height: abs(end.y - start.y)
            )
            path.addEllipse(in: rect)
        }
    }
    
    mutating func move(by offset: CGSize) {
        self.start = start + offset
        self.end = end + offset
    }
}
