//
//  SolveButtonView.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/18/23.
//

import SwiftUI

struct SolveButtonView: View {
    @EnvironmentObject var manager : GameManager
    
    var body: some View {
        Button("Solve") {
            withAnimation(.easeInOut) {manager.solve()}
        }
            .font(.largeTitle)
            .padding()
            .foregroundColor(.white)
            .background(RoundedRectangle(cornerRadius: 10)
                            .fill(.green))
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(const.outlineColor, lineWidth: const.outlineWidth)
                .opacity(const.boardOpacity))
            .disabled(!manager.hasPuzzle || manager.allCorrect)
            .opacity(manager.hasPuzzle && !manager.allCorrect ? const.buttonOpacity : const.disableOpacity)
            .animation(.easeInOut, value: !manager.hasPuzzle || manager.allCorrect)
    }
}
