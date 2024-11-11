//
//  Enums.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/15/23.
//

import Foundation

// used in CanvasView to determine current tool type
enum ToolType : Equatable, Codable {
    case pencil
    case eraser
    case shape(ShapeType)
    case interact
    case none
}

// used in CanvasView & ToolType to determine which element to draw
enum ShapeType : String, Equatable, Identifiable, CaseIterable, Codable {
    case triangle, rectangle, circle
    
    var id : String  { self.rawValue }
    var iconName : String  {
        switch self {
        case .triangle:
            "triangleshape"
        case .rectangle:
            "rectangle"
        case .circle:
            "circle"
        }
    }
}

// used in CanvasListView to sort local canvases
enum SortBy : String, CaseIterable, Identifiable {
    case lastModifiedDate = "last modified date", creationDate = "creation date"
    
    var id : String  { self.rawValue }
    var keyPath : KeyPath<Canvas, Date> {
        switch self {
        case .lastModifiedDate:
            \Canvas.lastModifiedDate
        case .creationDate:
            \Canvas.creationDate
        }
    }
    var iconName : String {
        switch self {
        case .lastModifiedDate:
            "pencil.and.outline"
        case .creationDate:
            "plus.app"
        }
    }
}

// used in CanvasListView to sort local canvases
enum MySortOrder : String, CaseIterable, Identifiable {
    case forward, reverse
    
    var id : String  { self.rawValue }
    var order : SortOrder {
        switch self {
        case .forward:
            .forward
        case .reverse:
            .reverse
        }
    }
    var iconName : String {
        switch self {
        case .forward:
            "chevron.down"
        case .reverse:
            "chevron.up"
        }
    }
}
