//
//  MapTopControlView.swift
//  Campus
//
//  Created by Andrew Wu on 10/1/23.
//

import SwiftUI

struct MapTopControlView: View {
    @Environment(Manager.self) var manager
    @Binding var currentSheet : SheetContent?
    @State private var isShowingAlert : Bool = false
    
    var body: some View {
        HStack{
            Spacer()
            
            // Show Building List
            Button(action: { currentSheet = .buildingsList }) {
                Image(systemName: "magnifyingglass.circle")
            }
            Spacer()
            
            // Find Direction
            Button(action: manager.hasRoutes ? {
                        manager.endRouting()
                        currentSheet = nil
                    } : { currentSheet = .directionRequest }
            ) {
                Image(systemName: manager.hasRoutes ? "arrow.triangle.turn.up.right.circle.fill" : "arrow.triangle.turn.up.right.circle")
            }
            Spacer()
            
            // Show Route Steps
            Button(action: currentSheet == .direction ? { currentSheet = nil } : { currentSheet = .direction }) {
                Image(systemName: currentSheet == .direction ? "list.bullet.circle.fill" : "list.bullet.circle")
            }
                .disabled(manager.steps.count == 0)
                .opacity(manager.steps.count == 0 ? 0.5 : 1.0)
            Spacer()
            
            // Toggle All Favorites
            Button(action: { manager.toggleAllFavorite() }) {
                Image(systemName: manager.isShowingAllFavorite ? "heart.fill" : "heart")
            }
            .foregroundColor(manager.hasFavorite ? .pink : .gray.opacity(0.5))
                .disabled(!manager.hasFavorite)
                .opacity(manager.hasFavorite ? 1.0 : 0.5)
            Spacer()
            
            // Toggle All Selections
            Button(action: { manager.toggleAllSelection() }) {
                Image(systemName: manager.isDeselectingAll ? "mappin.circle" : "mappin.circle.fill")
            }
            .foregroundColor(.primary)
            Spacer()
            
            // Remove All User-picked Markers
            Button(action: {isShowingAlert.toggle()}) {
                Image(systemName: "bookmark.slash.fill")
            }
                .foregroundColor(manager.userPickedLocations.isEmpty || currentSheet != nil ? .gray.opacity(0.5) : Color(red: 204/255, green: 0/255, blue: 0/255)
                )
                .scaleEffect(CGSize(width: 1.0, height: 0.9))
                .disabled(manager.userPickedLocations.isEmpty || currentSheet != nil)
                .opacity(manager.userPickedLocations.isEmpty ? 0.5 : 1.0)
                // deletion confirmation
                .alert(isPresented: $isShowingAlert) {
                    Alert(
                        title: Text("Delete All Added Markers?"),
                        message: Text("Do you want to remove all markers manually added by yourself?"),
                        primaryButton: .default(
                            Text("Cancel"),
                            action: {}
                        ),
                        secondaryButton: .destructive(
                            Text("Delete"),
                            action: { manager.userPickedLocations.removeAll()
                                if manager.userPickedDestination != nil {
                                    manager.endRouting()
                                }}
                        )
                    )
                }
            Spacer()
        }.font(.largeTitle)
    }
}

#Preview {
    MapTopControlView(currentSheet: .constant(nil))
        .environment(Manager())
}
