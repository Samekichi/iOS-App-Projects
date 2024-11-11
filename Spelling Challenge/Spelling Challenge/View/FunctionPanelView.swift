//
//  FunctionPanelView.swift
//  Spelling Challenge
//
//  Created by Andrew Wu on 8/27/23.
//

import SwiftUI

struct FunctionPanelView: View {
    
    @EnvironmentObject var gameManager : GameManager
    @State private var isPreferencesSheetPresented = false
    @State private var isHintsSheetPresented = false
    
    var body: some View {
        HStack{
            Spacer()
            FunctionPanelButton(icon: "shuffle", action: gameManager.shuffle)
            Spacer()
            FunctionPanelButton(icon: "arrow.clockwise", action: gameManager.newGame)
            Spacer()
            FunctionPanelButton(icon: "lightbulb", action: { isHintsSheetPresented.toggle() })
                .sheet(isPresented: $isHintsSheetPresented) { HintsView() }
            Spacer()
            FunctionPanelButton(icon: "gear", action: { isPreferencesSheetPresented.toggle() })
                .sheet(isPresented: $isPreferencesSheetPresented) { PreferencesView(preferences: $gameManager.preferences)
                        .presentationDetents([ .medium, .large])
                        .presentationBackground(.thinMaterial)
                }
            Spacer()
        }.padding(20)
    }
}


struct FunctionPanelButton: View {
    let icon : String
    let action : ()->()
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .frame(width: 33, height: 33)
        }
        .buttonStyle(.borderedProminent)
        .accentColor(Color("PrimaryColor"))
        .font(.headline)
    }
}
