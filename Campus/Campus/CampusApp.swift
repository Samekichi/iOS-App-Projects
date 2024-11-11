//
//  CampusApp.swift
//  Campus
//
//  Created by Andrew Wu on 10/1/23.
//

import SwiftUI

@main
struct CampusApp: App {
    @Environment(\.scenePhase) var scenePhase
    @State private var manager = Manager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
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
