//
//  DrawView.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/12/23.
//

import SwiftUI

struct DrawView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(MultiPeerManager.self) var manager
    
    var canvas : Canvas
    var elements : [AnyCanvasElement] {
        canvas.elements
    }
    
    /* Currently Drawing Element */
    @State private var currentStroke : CanvasStroke?
    @State private var currentShape : (any CanvasShape)?
    @State private var currentEraserPath : CanvasStroke?
    
    /* Tool Processing */
    @State var elementsBeingErased : Set<UUID> = []
    @Binding var refresh : Bool
    
    /* Gestures */
    private var gestureOnCanvas : some Gesture {
        [ToolType.none].contains(canvas.selectedTool) ? nil : drawGesture
    }
    // Interact Gesture
    @State private var lastDragTranslation : CGSize = .zero
    @State private var selectedElementIndex : Int?
    @State private var isMoveStarted : Bool = false
    // Draw Gesture
    private var drawGesture : some Gesture {
        DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
            // draw or pending deletion
            .onChanged { value in
                switch canvas.selectedTool {
                case .pencil:
                    if let stroke = currentStroke, stroke.points.last != value.location {
                        currentStroke!.points.append(value.location)
                    } else {  // create a new sstroke
                        currentStroke = CanvasStroke(cgColor: canvas.selectedColor.cgColor, linewidth: canvas.pencilThickness, willErase: false, points: [value.location])
                    }
                    
                case .eraser:
                    if let path = currentEraserPath, path.points.last != value.location {
                        currentEraserPath!.points.append(value.location)
                    } else {
                        currentEraserPath = CanvasStroke(cgColor: CGColor(red: 1, green: 1, blue: 1, alpha: 0.7), linewidth: canvas.eraserThickness, willErase: false, points: [value.location])
                    }
//                    withAnimation(.linear(duration: 0.15)) {
//                        willErase(at: value.location)
//                    }
                    
                case .shape(let shapeType):
                    if currentShape != nil {
                        currentShape!.end = value.location
                    } else {
                        switch shapeType {
                        case .triangle:
                            currentShape = CanvasTriangle(cgColor: canvas.selectedColor.cgColor, linewidth: canvas.shapeThickness, willErase: false, start: value.startLocation, end: value.location, isFilled: canvas.isShapeFilled)
                        case .rectangle:
                            currentShape = CanvasRectangle(cgColor: canvas.selectedColor.cgColor, linewidth: canvas.shapeThickness, willErase: false, start: value.startLocation, end: value.location, isFilled: canvas.isShapeFilled)
                        case .circle:
                            currentShape = CanvasCircle(cgColor: canvas.selectedColor.cgColor, linewidth: canvas.shapeThickness, willErase: false, start: value.startLocation, end: value.location, isFilled: canvas.isShapeFilled)
                        }
                    }
                case .interact:
                    if isMoveStarted {
                        if selectedElementIndex == nil {
                            break
                        } else {
                            // onChanged: update element position
                            if value.translation != lastDragTranslation {
                                let i = selectedElementIndex!
                                let offset = value.translation - lastDragTranslation
                                canvas.elements[i].element.move(by: offset)
                                lastDragTranslation = value.translation
                            }
                        }
                    } else {
                        isMoveStarted = true
                        selectedElementIndex = canvas.findFirstElement(at: value.location)
                        if selectedElementIndex != nil {
                            // onStarted: group actions for undo/redo
                            modelContext.undoManager?.beginUndoGrouping()
                        }
                    }
                case .none:
                    break
                }
            }
            // save or delete elements
            .onEnded { value in
                switch canvas.selectedTool {
                case .pencil:
                    if let stroke = currentStroke {
                        canvas.addElement(stroke)
                        // MPC action
                        if manager.isConnected {
                            let action = Action(actionType: .add, elementID: stroke.id, element: AnyCanvasElement(stroke))
                            manager.sendAction(action)
                        }
                        currentStroke = nil
                    }
                case .eraser:
                    withAnimation(.linear(duration: 0.1)) {
                        if let eraserPath = currentEraserPath {
                            willErase(on: eraserPath)
                        }
                        if elementsBeingErased.count > 0 {
                            erase()
                        }
                        currentEraserPath = nil
                    }
                case .shape:
                    if let shape = currentShape {
                        canvas.addElement(shape as (any CanvasElement))
                        // MPC action
                        if manager.isConnected {
                            let action = Action(actionType: .add, elementID: shape.id, element: AnyCanvasElement(shape))
                            manager.sendAction(action)
                        }
                        currentShape = nil
                    }
                case .interact:
                    if let i = selectedElementIndex {
                        canvas.lastModifiedDate = Date()
                        modelContext.undoManager?.endUndoGrouping()
                        // MPC action
                        if manager.isConnected {
                            let element = canvas.elements[i]
                            let action = Action(actionType: .move, elementID: element.element.id, element: element, translation: value.translation)
                            manager.sendAction(action)
                        }
                    }
                    isMoveStarted = false
                    selectedElementIndex = nil
                    lastDragTranslation = CGSize.zero
                case .none:
                    break
                }
                refresh.toggle()
            }
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            SwiftUI.Canvas(opaque: false, colorMode: .extendedLinear, rendersAsynchronously: true, renderer: { context, size in
                
                /* Existed elements */
                //                ForEach(canvas.elements, id:\.element.id) { element in
                for element in elements {
                    if let stroke = element.element as? CanvasStroke {
                        context.stroke(stroke.path(), with: .color(Color(stroke.canvasColor.cgColor)), lineWidth: stroke.linewidth)
                    } else if let shape = element.element as? (any CanvasShape) {
                        if shape.isFilled {
                            context.fill(shape.path(), with: .color(Color(shape.canvasColor.cgColor)))
                        } else {
                            context.stroke(shape.path(), with: .color(Color(shape.canvasColor.cgColor)), lineWidth: shape.linewidth)
                        }
                    }
                }
                
                /* Current drawing element */
                // Stroke
                if let stroke = currentStroke {
                    context.stroke(stroke.path(), 
                                   with: .color(Color(canvas.selectedColor.cgColor).opacity(0.9)),
                                   lineWidth: stroke.linewidth)
                }
                // Shape
                if let shape = currentShape {
                    if shape.isFilled {
                        context.fill(shape.path(), with: .color( Color(canvas.selectedColor.cgColor).opacity(0.9)))
                    } else {
                        context.stroke(shape.path(), 
                                       with: .color(Color(canvas.selectedColor.cgColor).opacity(0.9)),
                                       lineWidth: shape.linewidth)
                    }
                }
                // Eraser
                if let eraserStroke = currentEraserPath {
                    context.stroke(eraserStroke.path(), 
                                   with: .color(.white.opacity(0.5)),
                                   lineWidth: eraserStroke.linewidth)
                }
                
                // ZStack Center
                context.fill(Path(ellipseIn: CGRect(x: geometry.size.width / 2, y: geometry.size.height / 2, width: 10, height: 10)), with: .color(.blue.opacity(0.5)))

            }, symbols: {
                Text("Hi")
                    .background(.white)
                    .frame(width: 50, height: 50)
            })
        }
        .drawingGroup()
        .background(Color(canvas.backgroundColor))
        .gesture(
            gestureOnCanvas
        )
        
        
    }
}

//#Preview {
//    DrawView()
//        .environment(Manager())
//}

extension DrawView {
    
    private func erase() {
        canvas.elements.removeAll(where: { elementsBeingErased.contains($0.element.id) })
        // MPC action
        if manager.isConnected {
            let action = Action(actionType: .erase, elementIDs: elementsBeingErased)
            manager.sendAction(action)
        }
        canvas.lastModifiedDate = Date()
        elementsBeingErased.removeAll()
    }
    
    private func willErase(on erasePath: CanvasStroke) {
        for point in erasePath.points {
            for element in elements {
                if element.element.contains(point: point, threshold: canvas.eraserThickness) {
                    elementsBeingErased.insert(element.element.id)
                }
            }
        }
    }
}
