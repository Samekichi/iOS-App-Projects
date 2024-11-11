//
//  ConnectToHostView.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/29/23.
//

import SwiftUI
import SwiftData

struct ConnectToHostView: View {
    @Environment(MultiPeerManager.self) var manager
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.modelContext) private var modelContext
    @Query private var canvases: [Canvas]
    
    @Binding var isPrepared : Bool
    
    var body: some View {
        @Bindable var manager = manager
        
        NavigationStack {
            peerListView
                .navigationTitle("Nearby Hosts")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Dismiss") { dismiss() }
                    }
                }
                // Start MCP browsing on appear
                .onAppear {
                    manager.startBrowsing()
                }
                // End MCP browsing when host accept invitation
                .onChange(of: manager.canvas) { _, newCanvas in
                    if let newCanvas {
                        manager.stopBrowsing()
                        // SwiftData persist canvas
                        let canvasIDs = canvases.map { $0.id }
                        // delete old canvas
                        if canvasIDs.contains(newCanvas.id) {
                            do {
                                try modelContext.delete(model: Canvas.self, where: #Predicate { canvas in
                                    canvas.id == newCanvas.id
                                })
                                try modelContext.save()
                            } catch {
                                print("Deletion error: \(error)")
                            }
                        }
                        // insert new canvas to open
                        modelContext.insert(newCanvas)
                        do {
                            try modelContext.save()
                        } catch {
                            print(error)
                        }
                        isPrepared = true
                        dismiss()
                    }
                }
        }
    }
    
    private var peerListView : some View {
        Group {
            if manager.foundPeers.count == 0 {
                AnyView(
                    Text("No Peer Found")
                        .foregroundStyle(.primary.opacity(0.33))
                )
            } else {
                AnyView(
                    List {
                        ForEach(manager.foundPeers, id:\.self) { peer in
                            Button(action: {
                                manager.invitePeer(peer)
                            }) {
                                Text(peer.displayName)
                            }
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    ConnectToHostView(isPrepared: .constant(false))
        .environment(MultiPeerManager(username: UserDefaults.standard.string(forKey: "username") == nil ? "Unknown Username" : UserDefaults.standard.string(forKey: "username")!.isEmpty ? "Unknown Username" : UserDefaults.standard.string(forKey: "username")!))
}
