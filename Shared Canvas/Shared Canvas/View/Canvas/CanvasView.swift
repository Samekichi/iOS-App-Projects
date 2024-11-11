//
//  Canvas.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/12/23.
//

import SwiftUI
import SwiftData

struct CanvasView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(MultiPeerManager.self) var manager
    
    var canvas : Canvas
    
    /* Zoom */
    // anchor
    @State private var anchor = UnitPoint(x: 0.5, y: 0.5)
    // scale
    @State private var currentScale : Double = 1.0
    @State private var lastScale : Double = 1.0
    @State private var isChanging : Bool = false
    
    /* Pan */
    // offset
    @State private var currentOffset : CGSize = .zero
    
    /* Rotate */
    @State private var currentRotation : Angle = .zero
    @State private var lastRotation : Angle = .zero
    
    /* helper */
    // Undo & Redo
    @State private var refresh : Bool = false
    // Canvas Screenshot
    @Environment(\.displayScale) var displayScale
    @State private var toolbarHeight : Double = 50
    
    
    var body: some View {
        @Bindable var manager = manager
        ZStack(alignment: .top) {
            // Background
            Color.black
                .ignoresSafeArea()
            
            // Canvas
            GeometryReader { proxy in
                DrawView(canvas: canvas, refresh: $refresh)
                    .ignoresSafeArea()
                    .frame(width: canvas.width, height: canvas.height)
                    .scaleEffect(currentScale)
                    .rotationEffect(currentRotation)
                    .offset(currentOffset)
                    .position(x: proxy.size.width / 2, y: proxy.size.height/2 + toolbarHeight/2)
            }

            // Header
            VStack(alignment: .center) {
                ZStack {
                    // back to CanvasListView
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.backward")
                        }
                        .font(.title2)
                        .padding(.leading)
                        Spacer()
                        
                    }
                    // canvas name
                    VStack {
                        HStack {
                            Text(canvas.name)
                                .bold()
                                .lineLimit(2)
                        }
                        Text(canvas.lastModifiedDateString)
                            .font(.footnote)
                            .foregroundStyle(.primary.opacity(0.33))
                    }
                    /* helper: refresh after Undo/Redo */
                    Text(refresh.description).opacity(0).frame(width: 0, height: 0)
                }
                ToolBarView(canvas: canvas, refresh: $refresh)
            }
            .padding([.leading, .trailing])
            .background(Color("BackgroundColor"))
            .background {
                // get Header's height
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            toolbarHeight = proxy.size.height
                        }
                }
            }
        }
        .toolbar(.hidden)
        // Zoom gesture
        .simultaneousGesture(
            MagnifyGesture()
                .onChanged { value in
                    currentScale = min(10, max(0.1, lastScale * value.magnification))
                    if !isChanging {
                        anchor = value.startAnchor
                        isChanging = true
                    }
                }
                .onEnded { _ in
                    lastScale = currentScale
                    isChanging = false
                }
        )
        // Rotate gesture
        .simultaneousGesture(
            RotateGesture()
                .onChanged { value in
                    self.currentRotation = self.lastRotation + value.rotation
                }
                .onEnded { value in
                    self.lastRotation = self.currentRotation
                }
        )
        // MPC
        .alert(isPresented: $manager.receivedInvite) {
            Alert(
                title: Text("Peer Invitation"),
                message: Text("Received an invitation from \(manager.receivedInviteFrom?.displayName ?? "Unknown")!"),
                primaryButton: .default(Text("Accept")) {
                    if (manager.invitationHandler != nil) {
                        manager.invitationHandler!(true, manager.session)
                    }
                    manager.receivedInviteFrom = nil
                    manager.invitationHandler = nil
                },
                secondaryButton: .destructive(Text("Reject")) {
                    if (manager.invitationHandler != nil) {
                        manager.invitationHandler!(false, nil)
                    }
                    manager.receivedInviteFrom = nil
                    manager.invitationHandler = nil
                }
            )
        }
        .onAppear {
            if manager.isHosting {
                manager.canvas = canvas
            }
        }
        .onChange(of: canvas) {
            if manager.isHosting {
                manager.canvas = canvas
            }
        }
        .onDisappear {
            if manager.isConnected {
                manager.disconnect()
            } else if manager.isHosting {
                manager.stopAdvertising()
                manager.isHost = false
            }
        }
        // Update CoverImage
        .onDisappear { renderCanvasCoverImage() }
        // UndoManager
        .onAppear { modelContext.undoManager?.removeAllActions() }
        .onDisappear { modelContext.undoManager?.removeAllActions() }
    }
}

//#Preview {
//    CanvasView(canvas: Canvas.standard)
//        .environment(Manager())
//        .modelContainer(for: [Canvas.self])
//}

extension CanvasView {
    @MainActor
    func renderCanvasCoverImage() {
        let renderer = ImageRenderer(content:
            DrawView(canvas: canvas, refresh: $refresh)
                .frame(width: canvas.width, height: canvas.height)
                .environment(manager)
        )
        renderer.scale = displayScale

        if let uiImage = renderer.uiImage {
            let croppedUiImage = getCroppedUIImage(for: uiImage)
            
            DispatchQueue.global(qos: .userInitiated).async {
                if let coverImageData = croppedUiImage.pngData() {
                    DispatchQueue.main.async {
                        canvas.coverImageData = coverImageData
                    }
                }
            }
        }
    }
    
    func getCroppedUIImage(for uiImage: UIImage, withSize targetSize: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        let uiImageSize = uiImage.size
        let widthRatio  = targetSize.width / uiImageSize.width
        let heightRatio = targetSize.height / uiImageSize.height

        // determine UIImage's scale to fit its shorter edge to targetSize
        var newSize: CGSize
        if widthRatio < heightRatio {
            newSize = CGSize(width: uiImageSize.width * heightRatio, height: uiImageSize.height * heightRatio)
        } else {
            newSize = CGSize(width: uiImageSize.width * widthRatio, height: uiImageSize.height * widthRatio)
        }

        let fittedSize = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // get fitted UIImage
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        uiImage.draw(in: fittedSize)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // crop to targetSize
        guard let newCgImage = newImage?.cgImage else { return uiImage }

        let x = (newCgImage.width - Int(targetSize.width)) / 2
        let y = (newCgImage.height - Int(targetSize.height)) / 2
        let cropRect = CGRect(x: x, y: y, width: Int(targetSize.width), height: Int(targetSize.height))

        if let croppedCgImage = newCgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCgImage)
        }

        return uiImage
    }
}
