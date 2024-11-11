//
//  WelcomeScreen.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/16/23.
//

import SwiftUI

struct WelcomeScreen: View {
    @Environment(\.dismiss) var dismiss
    @State private var username: String = ""
    @FocusState private var isFocused : Bool
    
        var body: some View {
            VStack {
                Spacer()
                
                Text("Welcome to")
                    .font(.largeTitle)
                Text("Shared Canvas")
                    .font(.largeTitle)
                    .bold()
                TextField("Enter your username", text: $username)
                    .focused($isFocused)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Spacer()
                
                Button("Continue") {
                    saveUsernameAndGenerateID(username)
                    dismiss()
                }
                .disabled(username.isEmpty)
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
            .onAppear {
                isFocused = true
            }
        }

        func saveUsernameAndGenerateID(_ username: String) {
            let uuid = UUID().uuidString
            let userDefaults = UserDefaults.standard
            userDefaults.set(uuid, forKey: "userUUID")
            userDefaults.set(username, forKey: "username")
        }
}

#Preview {
    WelcomeScreen()
}
