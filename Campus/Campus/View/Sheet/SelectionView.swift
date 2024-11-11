//
//  SelectionView.swift
//  Campus
//
//  Created by Andrew Wu on 10/7/23.
//

import SwiftUI

struct SelectionView : View {
    @Environment(Manager.self) var manager
    @Binding var selection : Building?
    let title : String
    private var systemImage : String {
        return selection == nil ? "location.circle.fill" : "building.2.crop.circle.fill"
    }
    private var selectionString : String {
        return selection?.getName() ?? "Current Location"
    }
    
    var body : some View {
        HStack(alignment: .center) {
            Text(title.capitalized + " : ")
                .font(.title2)
                .bold()
            
            Menu {
                // Current user location
                Button(action: {selection = nil}) {
                    Label(title: {
                        Text("Current Location")
                    }, icon: {
                        Image(systemName: "location.fill")
                    })
                }
                Divider()
                .foregroundColor(.black)
                // Favorited buildings
                Section("Favorited Buildings") {
                    ForEach(manager.favoritedBuildings) { building in
                        DirectionSelectionRow(selection: $selection, building: building)
                    }
                }
                // Selected buildings
                Section("Selected Buildings") {
                    ForEach(manager.unfavoritedBuildings.filter {$0.isSelected}) { building in
                        DirectionSelectionRow(selection: $selection, building: building)
                    }
                }
                // Unselected buildings
                Section("Unselected Buildings") {
                    ForEach(manager.unfavoritedBuildings.filter {!$0.isSelected}) { building in
                        DirectionSelectionRow(selection: $selection, building: building)
                    }
                }
                
            } label: {
                Label(title: {
                    Text(selectionString)
                        .font(.title2)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)
                }, icon: {
                    Image(systemName: systemImage)
                })
            }
        }
    }
}

#Preview {
    SelectionView(selection: .constant(Building.constant), title: "from")
        .environment(Manager())
}


struct DirectionSelectionRow : View {
    @Environment(Manager.self) var manager
    @Binding var selection : Building?
    let building : Building
    
    var body : some View {
        Button(action: {selection = building}) {
            Label(title: {
                Text(building.getName())
            }, icon: {Image(systemName: building.isFavorited ? "heart.fill" : manager.isBuildingSelected(building) ? "checkmark.square.fill" : "square")})
            .foregroundColor(.black)
        }
    }
}
