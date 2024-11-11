//
//  Spelling_ChallengeApp.swift
//  Spelling Challenge
//
//  Created by Andrew Wu on 8/26/23.
//

import SwiftUI

@main
struct Spelling_ChallengeApp: App {
    
    @StateObject var gameManager = GameManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(GameManager())
        }
    }
}
