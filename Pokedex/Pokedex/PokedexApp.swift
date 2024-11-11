//
//  PokedexApp.swift
//  Pokedex
//
//  Created by Andrew Wu on 10/21/23.
//

import SwiftUI

@main
struct PokedexApp: App {
    @Environment(\.scenePhase) var scenePhase
    @State var manager = Manager()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(manager)
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .background, .inactive:
                        manager.save()
                    default:
                        break
                    }
                }
        }
    }
}
