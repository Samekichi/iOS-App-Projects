//
//  Shared_CanvasApp.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 11/12/23.
//

import SwiftUI
import SwiftData

@main
struct Shared_CanvasApp: App {
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("username") var username : String = ""
    
    var body: some Scene {
        WindowGroup {
            if username.isEmpty {
                WelcomeScreen()
            } else {
                HomeView(username: username)
                    .modelContainer(for: [Canvas.self], isUndoEnabled: true)
                    .environment(MultiPeerManager(username: username))
            }
        }
    }
}
