//
//  CanvasElement.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/13/23.
//

import Foundation
import SwiftUI
import SwiftData


protocol CanvasElement : Identifiable, Codable {
    var id : UUID  { get }
    
    var toolType : ToolType  { get set }
    var canvasColor : CanvasColor  { get set }
    var linewidth : Double  { get set }
    
    func contains(point: CGPoint, threshold: Double) -> Bool
    func render() -> AnyView
    func path() -> Path
    mutating func move(by offset: CGSize)
}

enum CanvasElementType: String, Codable {
    case stroke
    case triangle
    case rectangle
    case circle
}

struct AnyCanvasElement : Codable {
    var element : any CanvasElement
    
    init(_ element: any CanvasElement) {
            self.element = element
    }
    
    enum CodingKeys: CodingKey {
        case type
        case element
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch element {
        case let stroke as CanvasStroke:
            try container.encode(CanvasElementType.stroke, forKey: .type)
            try container.encode(stroke, forKey: .element)
        case let triangle as CanvasTriangle:
            try container.encode(CanvasElementType.triangle, forKey: .type)
            try container.encode(triangle, forKey: .element)
        case let rectangle as CanvasRectangle:
            try container.encode(CanvasElementType.rectangle, forKey: .type)
            try container.encode(rectangle, forKey: .element)
        case let circle as CanvasCircle:
            try container.encode(CanvasElementType.circle, forKey: .type)
            try container.encode(circle, forKey: .element)
        default:
            throw EncodingError.invalidValue(element, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unknown CanvasElementType"))
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CanvasElementType.self, forKey: .type)

        switch type {
        case .stroke:
            let stroke = try container.decode(CanvasStroke.self, forKey: .element)
            self.element = stroke
        case .triangle:
            let triangle = try container.decode(CanvasTriangle.self, forKey: .element)
            self.element = triangle
        case .rectangle:
            let rectangle = try container.decode(CanvasRectangle.self, forKey: .element)
            self.element = rectangle
        case .circle:
            let circle = try container.decode(CanvasCircle.self, forKey: .element)
            self.element = circle
        }
    }
}

protocol CanvasShape : CanvasElement {
    var start : CGPoint  { get set }
    var end : CGPoint  { get set }
    var isFilled : Bool  { get set }
    var shapeType : ShapeType  { get set }
}


