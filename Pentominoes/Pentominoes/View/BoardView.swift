//
//  BoardView.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/17/23.
//

import SwiftUI

struct BoardView: View {
    
    @EnvironmentObject var manager : GameManager
    // Board
    var unitBoardSize : Size {manager.getBoardSize()}
    var realBoardSize : CGSize {manager.getRealSize(unitBoardSize)}
    // Puzzle
    var currentPuzzle : Int {manager.currentPuzzle}
    var puzzle : PuzzleOutline  {manager.puzzles[currentPuzzle]}
    var unitPuzzleSize : Size {puzzle.size}
    var realPuzzleSize : CGSize {manager.getRealSize(unitPuzzleSize)}
    
    var body: some View {
        
        ZStack {
            // Board Fill
            Grid(m: unitBoardSize.height, n: unitBoardSize.width)
                .background(.white)
                .opacity(const.boardOpacity)
                .frame(width: realBoardSize.width, height: realBoardSize.height)
            
            // Puzzle Fill
            Puzzle(puzzle: manager.puzzles[currentPuzzle])
                .fill(const.puzzleColor, style: FillStyle(eoFill: true))
                .opacity(const.puzzleOpacity)
                .frame(width: realPuzzleSize.width, height: realPuzzleSize.height)
            // Board Grid
            Grid(m: unitBoardSize.height, n: unitBoardSize.width)
                .stroke(const.outlineColor, lineWidth: const.outlineWidth)
                .opacity(const.boardOpacity)
                .frame(width: realBoardSize.width, height: realBoardSize.height)
        }
        .position(manager.getRealPosition(for: manager.getBoardPosition(), with: unitBoardSize))
    }
}


struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView()
            .environmentObject(GameManager())
            .background(.gray)
    }
}
