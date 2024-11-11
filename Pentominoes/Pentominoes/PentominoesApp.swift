//
//  PentominoesApp.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/17/23.
//

import SwiftUI

@main
struct PentominoesApp: App {
    
    @StateObject var manager : GameManager = GameManager()
    
    var body: some Scene {
        WindowGroup {
            GameView()
                .environmentObject(manager)
        }
        
    }
}
