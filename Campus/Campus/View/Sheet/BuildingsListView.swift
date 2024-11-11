//
//  BuildingsListView.swift
//  Campus
//
//  Created by Andrew Wu on 10/1/23.
//

import SwiftUI


struct BuildingsListView : View {
    @Environment(Manager.self) var manager
    @Environment(\.dismiss) var dismiss
    @State private var filter : BuildingFilter = .all
    @State private var isShowingFilters = false
    var filteredBuildings : [Building]  { manager.getBuildings(by: filter) }
    var isAllFilteredBuildingsSelected : Bool  {
        return filteredBuildings.count > 0 && filteredBuildings.allSatisfy { $0.isSelected }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredBuildings) { building in
                    BuildingsListRow(building: building)
                }
            }
            .navigationBarTitle("\(self.filter.rawValue.capitalized) Buildings", displayMode: .inline)
            .navigationBarItems(trailing:
                HStack {
                    // Filter
                    Menu {
                        ForEach(BuildingFilter.allCases, id:\.self) {filter in
                            Button(action: { self.filter = filter }) {
                                Image(systemName: filter.systemName)
                                Text(filter.rawValue.capitalized)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    // Dismiss
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                    }
                }
            )
            .navigationBarItems(leading:
                Button(action: isAllFilteredBuildingsSelected ?
                    { manager.toggleAllOf(filteredBuildings, to: false)} :
                    { manager.toggleAllOf(filteredBuildings, to: true) }
                ) {
                    Image(systemName: isAllFilteredBuildingsSelected ? "checkmark.circle.fill" : "checkmark.circle")
                }
                .disabled(filteredBuildings.count == 0)
                .opacity(filteredBuildings.count == 0 ? 0.5 : 1.0)
            )
        }
    }
}

#Preview {
    BuildingsListView()
        .environment(Manager())
}


struct BuildingsListRow : View {
    @Environment(Manager.self) var manager
    let building : Building
    
    var body : some View {
        Button(action: {manager.toggleSelection(of: building)}) {
            Label(title: {
                Text(building.getName())
                if building.isFavorited {
                    Image(systemName: "heart.fill")
                }
            }, icon: {Image(systemName: manager.isBuildingSelected(building) ? "checkmark.square.fill" : "square")})
        }
        .foregroundColor(Color("InvAppearance"))
    }
}

enum BuildingFilter : String, CaseIterable {
    case all
    case favorited
    case selected
    case nearby
    
    var systemName : String {
        switch self {
        case .all:
            "building.2.fill"
        case .favorited:
            "heart.fill"
        case .selected:
            "checkmark.circle.fill"
        case .nearby:
            "location.north.fill"
        }
    }
}
