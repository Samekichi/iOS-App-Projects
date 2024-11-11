//
//  DirectionView.swift
//  Campus
//
//  Created by Andrew Wu on 10/7/23.
//

import SwiftUI

struct DirectionView: View {
    @Environment(Manager.self) var manager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        @Bindable var manager = manager
        let formattedEta : String = TimeInterval.getFormattedString(of: manager.eta)
        NavigationView {
            VStack{
                Text("\(manager.currentStepIndex + 1) of \(manager.steps.count)")
                    .font(.body)
                    .foregroundColor(.gray)
                    .bold()
                
                TabView(selection: $manager.currentStepIndex) {
                    ForEach(0..<manager.steps.count, id:\.self) { index in
                        VStack {
                            Text("\(manager.steps[index].instructions)")
                                .font(.title3)
                                .padding(.bottom)
                            Spacer()
                        }
                    }
                }
                .tabViewStyle(.page)
            }
            .navigationBarTitle("Route Steps (in \(formattedEta))", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    manager.endRouting()
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                }
            )
        }
    }
}

#Preview {
    DirectionView()
        .environment(Manager())
}
