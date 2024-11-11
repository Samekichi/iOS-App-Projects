//
//  ContentView.swift
//  Spelling Challenge
//
//  Created by Andrew Wu on 8/26/23.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var gameManager : GameManager
    
    var body: some View {
        VStack {
            TitleView(title: gameManager.title)
            TopHalfView()
            FoundWordsView(foundWords: gameManager.wordsFound)
            PickedLettersView(pickedLetters: gameManager.pickedLetters, mustHave: gameManager.mustHave)
            CandidateLettersView(candidateLetters: gameManager.candidateLetters)
            EditPanelView()
            ScoreView(score: gameManager.score)
            FunctionPanelView()
        }
        .background(Color("SecondaryColor"))
    }
}


struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(GameManager())
    }
}
