//
//  HomeView.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/18/23.
//

import SwiftUI
import SwiftData

struct CanvasListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(MultiPeerManager.self) var manager
    
    @Binding var selectedCanvasIDs : Set<UUID>
    @AppStorage("sortBy") var sortBy : SortBy = .lastModifiedDate
    
    @Query var sortedCanvases : [Canvas]
    init(sortBy: SortBy, sortOrder: MySortOrder, selectedCanvasIDs: Binding<Set<UUID>>, searchString: String) {
        _sortedCanvases = Query(
            filter: #Predicate<Canvas> {
                searchString.isEmpty ||
                $0.name.localizedStandardContains(searchString) ||
                $0.creatorIdentifier.username.localizedStandardContains(searchString)
            },
            sort: sortBy.keyPath,
            order: sortOrder.order)
        _selectedCanvasIDs = selectedCanvasIDs
    }
    
    @State private var showingEditCanvasSheet : Bool = false
    @State private var showingDeletionAlert : Bool = false
    @State private var canvasToModify : Canvas?
    
    var body: some View {
        List(selection: $selectedCanvasIDs) {
            ForEach(sortedCanvases) { canvas in
                NavigationLink {
                    CanvasView(canvas: canvas)
                } label: {
                    CanvasListRow(canvas: canvas)
                }
                .listRowBackground(selectedCanvasIDs.contains(canvas.id) ? Color.accentShallow.opacity(0.5) : Color.shallow)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // Delete
                    Button {
                        canvasToModify = canvas
                        showingDeletionAlert.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash").tint(Color(uiColor: .systemRed))
                    }
                    // Edit
                    Button {
                        canvasToModify = canvas
                        showingEditCanvasSheet.toggle()
                    } label: {
                        Label("Edit", systemImage: "pencil").tint(Color(uiColor: .systemOrange))
                    }
                }
            }
        }
        // Delete Canvas
        .alert("Delete Canvas", isPresented: $showingDeletionAlert, presenting: canvasToModify) { canvas in
            Button("Delete", role: .destructive) {
                withAnimation {
                    modelContext.delete(canvas)
                    canvasToModify = nil
                }
            }
        } message: { canvas in
            Text("Are you sure about deleting \"\(canvas.name)\" created by \(canvas.creatorIdentifier.username) at \(canvas.creationDateString)?")
        }
        // Edit Canvas
        .sheet(isPresented: $showingEditCanvasSheet) {
            CanvasParameterView(canvas: canvasToModify)
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
        }
    }
}

//#Preview {
//    HomeView()
//}

extension CanvasListView {
    private func deleteCanvases(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(sortedCanvases[index])
            }
        }
    }
}


struct CanvasListRow : View {
    @AppStorage("sortBy") var sortBy : SortBy = .lastModifiedDate
    var canvas : Canvas
    
    var body : some View {
        HStack{
            // Cover Image
            canvas.coverImage
                .frame(width: 100, height: 100, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.trailing)
            // Info
            VStack(alignment: .leading) {
                // canvas name
                Text(canvas.name)
                    .lineLimit(2)
                    .font(.title3)
                    .bold()
                // creator
                Text(canvas.creatorIdentifier.username)
                    .lineLimit(1)
                    .font(.body)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 3)
                // last modified / creation date
                HStack {
                    Image(systemName: sortBy.iconName)
                        .font(.caption)
                        .bold()
                    Text( sortBy == .lastModifiedDate ? canvas.lastModifiedDateString : canvas.creationDateString)
                        .lineLimit(1)       
                }
                .font(.caption2)
                .foregroundStyle(.gray.opacity(0.5))
            }
        }
    }
}
