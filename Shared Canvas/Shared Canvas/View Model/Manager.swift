//
//  Manager.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/12/23.
//

import Foundation
import CoreGraphics
import SwiftData

@Observable
class Manager {
    /* Model Data */
    
    var currentCanvas : Canvas?
    /* Manager Fields */
    var elementsBeingErased : Set<UUID> = []
    /* View States */
    var canvasElements : [any CanvasElement] = []
    // canvas parameters
    var selectedTool : ToolType = .pencil
    var selectedShape : ShapeType = .triangle
    var selectedColor : CGColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
    // tool Parameters
    var isShapeFilled : Bool = false
    var pencilThickness : CGFloat = 3.0
    var eraserThickness : CGFloat = 3.0
    var shapeThickness : CGFloat = 3.0
    
    
    
    init() {
//        currentCanvas = Canvas(
//            name: "Test Canvas",
//            creatorIdentifier: "Anonymous Testor 001")
//        do {
//            container = try ModelContainer(for: CanvasColor.self)
//        } catch {
//            print(error)
//        }
    }
    
    // Canvas Operations
    func addElement(_ element: any CanvasElement) {
        canvasElements.append(element)
    }
    
    func willErase(at point: CGPoint) {
        for i in canvasElements.indices {
            if canvasElements[i].contains(point: point, threshold: eraserThickness) {
//                canvasElements[i].willErase = true
                elementsBeingErased.insert(canvasElements[i].id)
            }
        }
    }
    
    func erase() {
        canvasElements.removeAll(where: { elementsBeingErased.contains($0.id) })
    }
    
    // Persistence
    func load() {
        
    }
    
    func save() {
        
    }
}
