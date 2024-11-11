//
//  HomeView.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/14/23.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Canvas.lastModifiedDate, order: .reverse) private var canvases: [Canvas]
    @Environment(MultiPeerManager.self) var manager
    
    @AppStorage("username") var username : String = ""
    @AppStorage("sortBy") var sortBy : SortBy = .lastModifiedDate
    @AppStorage("sortOrder") var sortOrder : MySortOrder = .reverse
    
//    var manager : MultiPeerManager
    @State private var sharedCanvas : Canvas?
    @State private var isSharedCanvasPrepared = false
    
    @State private var selectedCanvasIDs : Set<UUID> = []
    @State private var canvasesToDelete : Set<UUID> = []
    @State private var searchString : String = ""
    
    @State private var showingDeletionAlert = false
    @State private var showingSharedCanvas = false
    @State private var showingAddCanvasSheet = false
    @State private var showingConnectToHostSheet = false
    
    private var titleUsername : String  {
        if let _name = UserDefaults.standard.string(forKey: "username"), _name != "" {
            return _name+"'s"
        } else {
            return "Your"
        }
    }
    
//    init(username: String) {
//        self.manager = MultiPeerManager(username: username)
//    }
    
    var body: some View {

        NavigationStack {
            CanvasListView(sortBy: sortBy, sortOrder: sortOrder, selectedCanvasIDs: $selectedCanvasIDs, searchString: searchString)
                .navigationTitle("\(titleUsername) Canvases")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchString, prompt: "Search for Canvas or Creator's Name")
                .onAppear { selectedCanvasIDs.removeAll() }  // clear weird selection of the opened canvas' list item
                // Edit Mode's Deletion Alert
                .alert("Delete Canvas", isPresented: $showingDeletionAlert) {
                    Button("Delete", role: .destructive) {
                        withAnimation {
                            deleteCanvases(uuids: canvasesToDelete)
                            canvasesToDelete.removeAll()
                        }
                    }
                } message: {
                    Text("Are you sure about deleting the selected \(selectedCanvasIDs.count) canvases?")
                }
                .toolbar {
                    /* Top Leading */
                    // delete canvases
                    ToolbarItem(placement: .topBarLeading) {
                        Button(role: .destructive, action: {
                            canvasesToDelete = selectedCanvasIDs
                            showingDeletionAlert = true
//                            deleteCanvases(uuids: selectedCanvasIDs)
                        }) {
                            Label("Delete Canvases", systemImage: "trash")
                        }
                        .disabled(selectedCanvasIDs.count == 0)
                    }
                    
                    // delete user identifier
                    ToolbarItem(placement: .topBarLeading) {
                        Button(role: .destructive, action: {
                            UserDefaults.standard.setValue("", forKey: "username")
                            UserDefaults.standard.setValue("", forKey: "userUUID")
                        }) {
                            Label("Delete User Profile", systemImage: "person.slash.fill")
                        }
                    }
                    // join a canvas host
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            showingConnectToHostSheet = true
                        }) {
                            Label("Connect to a Canvas", systemImage: "badge.plus.radiowaves.right")
                        }
                        .navigationDestination(isPresented: $showingSharedCanvas) {
                            CanvasView(canvas: sharedCanvas ?? Canvas.standard)
                                .onDisappear {
                                    print("CanvasView .onDisappear()")
                                    showingSharedCanvas = false
                                }
                        }
                        .onChange(of: isSharedCanvasPrepared) { _, _ in
                            if isSharedCanvasPrepared {
                                if manager.canvas != nil {
                                    fetchModelOfSharedCanvas()
                                    isSharedCanvasPrepared = false
                                    showingSharedCanvas = true
                                }
                            }
                        }
                        .onChange(of: manager.connectedPeersCount) { _, count in
//                            print("manager.connectedPeersCount changed to \(manager.connectedPeersCount)!")
                            if count == 0 {
//                                showingSharedCanvas = false
                            }
                        }
                    }
                    
                    /* Top Trailing */
                    // sort canvas
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Section {  // sort by
                                ForEach(SortBy.allCases) { rule in
                                    Button(action: { sortBy = rule }) {
                                        HStack {
                                            if sortBy == rule {
                                                Image(systemName: "checkmark")
                                            }
                                            Text(rule.rawValue.capitalized)
                                        }
                                    }
                                }
                            } header: { Text("sort by".uppercased()) }
                            
                            Section {  // sort order
                                ForEach(MySortOrder.allCases) { order in
                                    Button(action: { sortOrder = order }) {
                                        HStack {
                                            if sortOrder == order {
                                                Image(systemName: "checkmark")
                                            }
                                            Text(order.rawValue.capitalized)
                                        }
                                    }
                                }
                            } header: { Text("sort order".uppercased()) }
                        } label: {
                            Label("Sort By", systemImage: "arrow.up.arrow.down")
                        } primaryAction: {
                            sortOrder = sortOrder == .forward ? .reverse : .forward
                        }
                       
                    }
                    // add canvas
                    ToolbarItem(placement: .topBarTrailing) {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.accentColor)
                            .gesture(
                                LongPressGesture(minimumDuration: 1.0).onEnded { _ in
                                    guard let username = UserDefaults.standard.string(forKey: "username") else { return }
                                    guard let userUUIDString = UserDefaults.standard.string(forKey: "userUUID") else { return }
                                    let creatorIdentifier = CreatorIdentifier(username: username, userUUIDString: userUUIDString)
                                    
                                    let defaultNewCanvas = Canvas(name: "A Default Canvas", creatorIdentifier: creatorIdentifier)
                                    modelContext.insert(defaultNewCanvas)
                                }
                            )
                            .simultaneousGesture(
                                TapGesture().onEnded { _ in
                                    showingAddCanvasSheet.toggle()
                                }
                            )
                    }
                    // edit canvas list
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                }
        }
        .sheet(isPresented: $showingAddCanvasSheet) {
            CanvasParameterView()
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showingConnectToHostSheet, onDismiss: {
            manager.stopBrowsing()
            manager.stopAdvertising()
        }) {
            ConnectToHostView(isPrepared: $isSharedCanvasPrepared)
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
        }
    }
}

#Preview {
//    HomeView(username: UserDefaults.standard.string(forKey: "username") == nil ? "Unknown Username" : UserDefaults.standard.string(forKey: "username")!.isEmpty ? "Unknown Username" : UserDefaults.standard.string(forKey: "username")!)
//        .modelContainer(for: [Canvas.self])
//        .environment(MultiPeerManager(username: UserDefaults.standard.string(forKey: "username") == nil ? "Unknown Username" : UserDefaults.standard.string(forKey: "username")!.isEmpty ? "Unknown Username" : UserDefaults.standard.string(forKey: "username")!))
    
    HomeView()
        .modelContainer(for: [Canvas.self])
        .environment(MultiPeerManager(username: UserDefaults.standard.string(forKey: "username") == nil ? "Unknown Username" : UserDefaults.standard.string(forKey: "username")!.isEmpty ? "Unknown Username" : UserDefaults.standard.string(forKey: "username")!))
}


extension HomeView {
    private func deleteCanvases(uuids: Set<UUID>) {
        withAnimation {
            for canvas in canvases {
                if uuids.contains(canvas.id) {
                    modelContext.delete(canvas)
                }
            }
        }
    }
    
    private func fetchModelOfSharedCanvas() {
        sharedCanvas = nil
        if let canvas = manager.canvas {
            let id = canvas.id
            let predicate = #Predicate<Canvas> { canvas in
                canvas.id == id
            }
            let fd = FetchDescriptor(predicate: predicate)
            do {
                let filteredCanvases = try modelContext.fetch(fd)
                if filteredCanvases.count >= 1 {
                    sharedCanvas = filteredCanvases[0]
                    manager.canvas = sharedCanvas
                }
            } catch {
                print(error)
            }
        }
    }
}
