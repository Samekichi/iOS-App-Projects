//
//  Canvas.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/13/23.
//

import Foundation
import SwiftUI
import SwiftData
//import CoreLocation

@Model
class Canvas : Identifiable, Codable {
    
    /* Canvas */
    // File Data
    @Attribute(.unique) var id = UUID()
    var name : String
    var creatorIdentifier : CreatorIdentifier
    var creationDate : Date
    var lastModifiedDate : Date
    var creationDateString : String  {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        return formatter.string(from: creationDate)
    }
    var lastModifiedDateString : String  {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        return formatter.string(from: lastModifiedDate)
    }
    var coverImageData : Data = Data()
    var coverImage : Image {
        if let uiImage = UIImage(data: coverImageData) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "paintpalette")
        }
    }
    
    // Canvas Parameters
    var width : Double = 400
    var height : Double = 600
    var backgroundCanvasColor : CanvasColor = CanvasColor(CGColor.white)
    var backgroundColor : Color  { Color(backgroundCanvasColor.cgColor) }
    
    // Canvas Elements
    var elements : [AnyCanvasElement] = []
        
    // Canvas Tool Parameters
    var selectedTool : ToolType = ToolType.pencil
    var selectedShape : ShapeType = ShapeType.triangle
    var selectedColor : CanvasColor = CanvasColor(CGColor.black)
    
    // Tool Parameters
    var isShapeFilled : Bool = false
    var pencilThickness : Double = 3.0
    var eraserThickness : Double = 10.0
    var shapeThickness : Double = 3.0
    
    init(name: String = "", creatorIdentifier: CreatorIdentifier, creationDate: Date = Date(), lastModifiedDate: Date = Date(), width: Double = 400, height: Double = 600, backgroundCanvasColor: CanvasColor = CanvasColor(CGColor.white)) {
        if name.isEmpty {
            self.name = "A Canvas"
        } else {
            self.name = name
        }
        self.creatorIdentifier = creatorIdentifier
        self.creationDate = creationDate
        self.lastModifiedDate = lastModifiedDate
        self.width = width
        self.height = height
        self.backgroundCanvasColor = backgroundCanvasColor
    }
    
    
    /* Codable */
    enum CodingKeys: String, CodingKey {
        case id, name, creatorIdentifier, creationDate, lastModifiedDate, width, height, backgroundCanvasColor, elements
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(creatorIdentifier, forKey: .creatorIdentifier)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(lastModifiedDate, forKey: .lastModifiedDate)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(backgroundCanvasColor, forKey: .backgroundCanvasColor)
        try container.encode(elements, forKey: .elements)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        creatorIdentifier = try container.decode(CreatorIdentifier.self, forKey: .creatorIdentifier)
        creationDate = try container.decode(Date.self, forKey: .creationDate)
        lastModifiedDate = try container.decode(Date.self, forKey: .lastModifiedDate)
        width = try container.decode(CGFloat.self, forKey: .width)
        height = try container.decode(CGFloat.self, forKey: .height)
        backgroundCanvasColor = try container.decode(CanvasColor.self, forKey: .backgroundCanvasColor)
        elements = try container.decode([AnyCanvasElement].self, forKey: .elements)
    }
}

// Tool Functions
extension Canvas {
    func addElement(_ element: any CanvasElement) {
        elements.append(AnyCanvasElement(element))
        lastModifiedDate = Date()
    }
    
    func findFirstElement(at point: CGPoint) -> Int? {
        for i in elements.indices.reversed() {
            if elements[i].element.contains(point: point, threshold: eraserThickness) {
                return i
            }
        }
        return nil
    }
    
}

// A Standard Canvas
extension Canvas {
    static let standard = Canvas(name: "Standard Canvas", creatorIdentifier: CreatorIdentifier(username: "Testor01", userUUIDString: UUID().uuidString))
}
