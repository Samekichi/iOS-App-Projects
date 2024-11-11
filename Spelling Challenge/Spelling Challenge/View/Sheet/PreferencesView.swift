//
//  PreferencesView.swift
//  Spelling Challenge
//
//  Created by Andrew Wu on 9/10/23.
//

import SwiftUI

struct PreferencesView: View {
    
    @EnvironmentObject var gameManager : GameManager
    @Environment(\.dismiss) private var dismiss
    @Binding var preferences : Preferences
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Language")) {
                    Picker("Language", selection: $preferences.language) {
                        ForEach(Language.allCases) { language in
                            Text(language.rawValue.capitalized).tag(language)
                        }
                    }.pickerStyle(.segmented)
                }
                Section(header: Text("Number of Letters")) {
                    Picker("Number of Letters", selection: $preferences.numberOfLetters) {
                        ForEach(NumberOfLetters.allCases) { num in
                            Text(num.rawValue).tag(num)
                        }
                    }.pickerStyle(.segmented)
                }
            }
            .navigationBarTitle("Preferences", displayMode: .inline)
            .navigationBarItems(trailing: Button("Dismiss") { dismiss() })
        }
    }
}

//struct PreferencesView_Preview : PreviewProvider {
//    static var previews: some View {
//        @State var preferences = Preferences(language: .english, numberOfLetters: .five)
//        PreferencesView(preferences: $preferences)
//            .environmentObject(GameManager())
//    }
//}
