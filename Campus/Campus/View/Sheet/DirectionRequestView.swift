//
//  DirectionRequestView.swift
//  Campus
//
//  Created by Andrew Wu on 10/7/23.
//

import SwiftUI

struct DirectionRequestView: View {
    @Environment(Manager.self) var manager
    @Environment(\.dismiss) var dismiss
    @Binding var currentSheet : SheetContent?
    
    var body: some View {
        @Bindable var manager = manager
        
        NavigationView {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    SelectionView(selection: $manager.source, title: "from")
                    SelectionView(selection: $manager.destination, title: "to")
                }
                .padding([.leading, .trailing])
                Spacer()
                Button("Go", action: {
                    manager.getRoute(from: manager.source, to: manager.destination)
                    currentSheet = .direction
                })
                    .font(.largeTitle)
                    .padding()
                    .background(.green)
                    .foregroundColor(.white)
                    .cornerRadius(18.0)
                    .padding(.trailing)
            }
            .navigationBarTitle("Route Planning", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {dismiss()}) {
                    Image(systemName: "xmark")
                        .font(.title3)
            })
        }
    }
}

#Preview {
    DirectionRequestView(currentSheet: .constant(nil))
        .environment(Manager())
}



