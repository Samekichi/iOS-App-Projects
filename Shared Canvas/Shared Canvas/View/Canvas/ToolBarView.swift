//
//  ToolBarView.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/12/23.
//

import SwiftUI
import SwiftData

struct ToolBarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(MultiPeerManager.self) var manager
    
    var canvas : Canvas
    
    // ColorPicker
    @State private var selectedColor : CGColor = CGColor.random()
    // Popover Status
    @State private var isPencilPopoverPresented : Bool = false
    @State private var isEraserPopoverPresented : Bool = false
    @State private var isShapePopoverPresented : Bool = false
    @State private var isConnectedPeersPopoverPresented : Bool = false
    @State private var showingEditCanvasSheet : Bool = false
    
    @Binding var refresh : Bool
    
    var body: some View {
        @Bindable var canvas = canvas
        
        ZStack(alignment: .center) {
            HStack(alignment: .center) {
                /* MARK: Leading - Tools */
                // Pencil
                Button("Pencil",
                       systemImage: canvas.selectedTool == .pencil ? "pencil.tip.crop.circle.fill" : "pencil.tip.crop.circle",
                       action: {}
                )
                .foregroundStyle(.white.opacity(0.8))
                .labelStyle(.iconOnly)
                .font(.title)
                .simultaneousGesture(LongPressGesture().onEnded { _ in
                    isPencilPopoverPresented.toggle()
                })
                .simultaneousGesture(TapGesture().onEnded {
                    modelContext.undoManager?.disableUndoRegistration()
                    if canvas.selectedTool != .pencil {
                        canvas.selectedTool = .pencil
                    } else {
                        canvas.selectedTool = .none
                    }
                    modelContext.undoManager?.enableUndoRegistration()
                })
                .popover(isPresented: $isPencilPopoverPresented) {
                    PencilPopoverView(pencilThickness: $canvas.pencilThickness)
                        .frame(minWidth: 250)
                }
                Spacer()
                
                // Eraser
                Button("Eraser",
                       systemImage: canvas.selectedTool == .eraser ? "eraser.line.dashed.fill" : "eraser.line.dashed",
                       action: {}
                )
                .foregroundStyle(.white.opacity(0.8))
                .labelStyle(.iconOnly)
                .font(.title)
                .simultaneousGesture(LongPressGesture().onEnded { _ in
                    isEraserPopoverPresented.toggle()
                })
                .simultaneousGesture(TapGesture().onEnded {
                    modelContext.undoManager?.disableUndoRegistration()
                    if canvas.selectedTool != .eraser {
                        canvas.selectedTool = .eraser
                    } else {
                        canvas.selectedTool = .none
                    }
                    modelContext.undoManager?.enableUndoRegistration()
                })
                .popover(isPresented: $isEraserPopoverPresented) {
                    EraserPopoverView(eraserThickness: $canvas.eraserThickness)
                        .frame(minWidth: 250)
                }
                Spacer()
                
                // Shapes
                Button("Shapes",
                       systemImage: canvas.selectedTool == .shape(canvas.selectedShape) ? canvas.selectedShape.iconName + ".fill" : canvas.selectedShape.iconName,
                       action: {}
                )
                .foregroundStyle(.white.opacity(0.8))
                .labelStyle(.iconOnly)
                .font(.title)
                .simultaneousGesture(LongPressGesture().onEnded { _ in
                    isShapePopoverPresented.toggle()
                })
                .simultaneousGesture(TapGesture().onEnded {
                    modelContext.undoManager?.disableUndoRegistration()
                    if canvas.selectedTool != .shape(canvas.selectedShape) {
                        canvas.selectedTool = .shape(canvas.selectedShape)
                    } else {
                        canvas.selectedTool = .none
                    }
                    modelContext.undoManager?.enableUndoRegistration()
                })
                .popover(isPresented: $isShapePopoverPresented) {
                    ShapePopoverView(isShapeFilled: $canvas.isShapeFilled, shapeThickness: $canvas.shapeThickness, selectedShape: $canvas.selectedShape, selectedTool: $canvas.selectedTool)
                        .frame(minWidth: 250)
                }
                
                // Interact
                Button("Interact",
                        systemImage: canvas.selectedTool == .interact ? "rectangle.and.hand.point.up.left.fill" : "rectangle.and.hand.point.up.left",
                        action: {
                            modelContext.undoManager?.disableUndoRegistration()
                            if canvas.selectedTool != .interact {
                                canvas.selectedTool = .interact
                            } else {
                                canvas.selectedTool = .none
                            }
                            modelContext.undoManager?.enableUndoRegistration()
                        }
                )
                .foregroundStyle(.white.opacity(0.8))
                .labelStyle(.iconOnly)
                .font(.title)
                Spacer()
                
                // Color Picker
                ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                    .scaleEffect(1.33, anchor: UnitPoint(x: 1, y: 0.5))
                    .padding(.trailing, 5)
                Spacer()
                
                
                /* MARK: Center - Undo & Redo */
                // Undo
                Button("Undo",
                       systemImage: "arrow.uturn.backward.circle",
                       action: {}
                )
                .simultaneousGesture(LongPressGesture().onEnded { _ in
                    while modelContext.undoManager?.canUndo != nil && modelContext.undoManager!.canUndo {
                        modelContext.undoManager?.undo()
                    }
                    refresh.toggle()
                })
                .simultaneousGesture(TapGesture().onEnded {
                    modelContext.undoManager?.undo()
                    refresh.toggle()
                })
                .disabled(modelContext.undoManager == nil || modelContext.undoManager!.canUndo == false || (manager.isConnected || manager.canvas != nil) )
                .foregroundStyle(.white.opacity(0.8))
                .labelStyle(.iconOnly)
                .font(.title)
                .opacity(modelContext.undoManager == nil || modelContext.undoManager!.canUndo == false ? 0.33 : 1.0)
                Spacer()
                
                // Redo
                Button("Redo",
                       systemImage: "arrow.uturn.forward.circle",
                       action: {}
                )
                .simultaneousGesture(LongPressGesture().onEnded { _ in
                    while modelContext.undoManager?.canRedo != nil && modelContext.undoManager!.canRedo {
                        modelContext.undoManager?.redo()
                    }
                    refresh.toggle()
                })
                .simultaneousGesture(TapGesture().onEnded {
                    modelContext.undoManager?.redo()
                    refresh.toggle()
                })
                .disabled(modelContext.undoManager?.canRedo == nil || modelContext.undoManager?.canRedo == false || (manager.isConnected || manager.canvas != nil) )
                .foregroundStyle(.white.opacity(0.8))
                .labelStyle(.iconOnly)
                .font(.title)
                .opacity(modelContext.undoManager?.canRedo == nil || modelContext.undoManager?.canRedo == false ? 0.33 : 1.0)
                .padding(.trailing, 5)
                Spacer()
                
                
                /* MARK: Trailing - Settings */
                // Canvas Setting
                Button("Cavas Setting", systemImage: "pencil.and.list.clipboard", action: {
                    // Cavas Setting
                    showingEditCanvasSheet.toggle()
                })
                .foregroundStyle(.white.opacity(0.8))
                .labelStyle(.iconOnly)
                .font(.title)
                .sheet(isPresented: $showingEditCanvasSheet) {
                    CanvasParameterView(canvas: canvas)
                        .presentationDetents([.medium])
                }
                Spacer()
                
                // Multi-Peer Control
                Button(action: {}) {
                    if manager.isConnected || manager.isHosting {
                        VStack {
                            Image(systemName: "person.crop.circle.fill.badge.plus")
                                .font(.body)
                            Text("\(manager.connectedPeersCount)")
                                .font(.caption2)
                        }
                    } else {
                        Label("Multi-Peer Control", systemImage: "person.crop.circle.fill.badge.plus")
                    }
                }
                .simultaneousGesture(  // Show connected peers
                    LongPressGesture(minimumDuration: 1.05).onEnded { _ in
                        if manager.isConnected {
                            isConnectedPeersPopoverPresented.toggle()
                        }
                })
                .simultaneousGesture( // MPC host switch
                    TapGesture().onEnded {
                        if manager.isConnected && !manager.isHost {
                            // disconnect if client is connected as a peer
                            manager.disconnect()
                        }
                        else {
                            if manager.isHosting {  // stop hosting
                                manager.disconnect()
                            } else {  // start to host
                                manager.prepareSharedCanvas(canvas)
                                manager.startAdvertising()
                            }
                        }
                })
                .popover(isPresented: $isConnectedPeersPopoverPresented) {
                    ConnectedPeersPopoverView()
                        .frame(minWidth: 200, minHeight: 225)
                        
                }
                .foregroundStyle(manager.isHosting || manager.isConnected ? .green : .white.opacity(0.8))
                .labelStyle(.iconOnly)
//                .disabled(manager.isConnected && !manager.isHost)
                .opacity(manager.isConnected && !manager.isHost ? 0.33 : 1.0)
                .font(.title)
            }
            .onAppear {
                selectedColor = canvas.selectedColor.cgColor
            }
            .onChange(of: selectedColor) { _, newColor in
                // Sync ColorPicker color
                modelContext.undoManager?.disableUndoRegistration()
                canvas.selectedColor = CanvasColor(newColor)
                modelContext.undoManager?.enableUndoRegistration()
                refresh.toggle()
            }
            .onChange(of: canvas.selectedTool) { _, _ in
                // Refresh undo/redo disability
                refresh.toggle()
            }
        }
        
        /* helper: refresh after Undo/Redo */
        Text(refresh.description).opacity(0).frame(width: 0, height: 0)
    }
}

//#Preview {
//    ToolBarView()
//}
