//
//  BuildingDetailView.swift
//  Campus
//
//  Created by Andrew Wu on 10/1/23.
//

import SwiftUI

struct BuildingDetailView: View {
    @Environment(Manager.self) private var manager
    @Environment(\.dismiss) var dismiss
    @Binding var currentSheet : SheetContent?
    var building : Building
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                // Info
                HStack {
                    VStack(alignment: .leading) {
                        // Building name
                        Text(building.getName())
                            .font(.title)
                            .fixedSize(horizontal: false, vertical: true)
                        // Year of construction
                        Text(building.getYearOfConstruction())
                            .font(.body)
                    }
                    Spacer()
                    Button(action: {dismiss()}) {
                        Image(systemName:"xmark")
                            .font(.largeTitle)
                    }
                }.padding([.bottom])
                // Functionalities
                HStack {
                    // Favorite?
                    ActionButton(
                        title: manager.isBuildingFavorited(building) ? "Unfavorite" : "Favorite",
                        icon: manager.isBuildingFavorited(building) ? "heart.fill" : "heart",
                        action: { manager.toggleFavorite(of: building) }
                    )
                    Spacer()
                    // Walk from current location to the building
                    ActionButton(
                        title: "Direct To",
                        icon: "figure.walk",
                        action: {
                            manager.source = nil
                            manager.destination = building
                            manager.getRoute(to: building)
                            currentSheet = .direction
                            
                        }
                    )
                    Spacer()
                    // Walk from the building to another place
                    ActionButton(
                        title: "Start From",
                        icon: "figure.walk",
                        action: {
                            manager.source = building
                            manager.destination = nil
                            currentSheet = .directionRequest
                        }
                    )
                }
                .buttonStyle(.borderedProminent)
                // Image
                if building.hasPhoto() {
                    Image(building.getPhoto())
                        .resizable()
                        .scaledToFit()
                        .padding(.top)
                }
            }
            .padding()
        }
    }
}

#Preview {
    BuildingDetailView(currentSheet: .constant(nil), building: .constant)
        .environment(Manager())
}


struct ActionButton : View {
    let title : String
    let icon : String
    let action : () -> Void
    let width : Double = 85
    let height : Double = 40
    var body : some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
            }
            .frame(width: width, height: height)
        }
    }
}
