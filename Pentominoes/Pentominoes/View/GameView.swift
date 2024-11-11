//
//  GameView.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/17/23.
//

import SwiftUI

struct GameView: View {
    
    @EnvironmentObject var manager : GameManager
    var body: some View {
        
        VStack {
            HStack(alignment: .top) {
                Spacer()
                VStack {
                    BoardButtonsView(boardRange: 0...3)  // left 4 buttons
                    ResetButtonView()
                }.padding()
                ZStack(alignment: .topTrailing){
                    BoardView()
                    ForEach($manager.pieces) { $piece in
                        PieceView(piece: $piece)
                    }
                }
                VStack {
                    BoardButtonsView(boardRange: 4...7)  // right 4 buttons
                    SolveButtonView()
                }
                .padding()
                Spacer()
            }
            Spacer()
        }
        .padding()
        .background(Color("SecondaryColor"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(GameManager())
    }
}
