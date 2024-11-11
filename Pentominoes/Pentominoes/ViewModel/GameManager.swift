//
//  GameManager.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/17/23.
//

import Foundation

class GameManager : ObservableObject {
    // Persistences
    private let pentominoesPersistence : Persistence<[PentominoOutline]>
    private let puzzlesPersistence : Persistence<[PuzzleOutline]>
    private let solutionsPersistence : Persistence<[ String : [ String : Position ]]>
    // Models
    @Published var pieces : [ Piece ]
    var puzzles : [ PuzzleOutline ]
    var solutions : [ String : [ String : Position ]]
    // Parameters
    let blockSize : Int = 40
    let pieceBasePosition : Position = Position(x: -1, y: 17)
    // Game Status
    @Published var currentPuzzle : Int
    var currentSolution : [String : Position] {solutions[puzzles[currentPuzzle].name]!}
    var hasPuzzle : Bool {currentPuzzle != 0}
    var isAllPiecesInDefault : Bool { pieces.allSatisfy {isPieceInDefault($0)} }
    var allCorrect : Bool { pieces.allSatisfy {isCorrect($0)}}
    // Initalizer
    init() {
        // load json
        self.pentominoesPersistence = Persistence(fileName: "PentominoOutlines")
        self.puzzlesPersistence = Persistence(fileName: "PuzzleOutlines")
        self.solutionsPersistence = Persistence(fileName: "Solutions")
        // get properties
        let pentominoOutlines = pentominoesPersistence.items ?? []
        self.pieces = pentominoOutlines.map { Piece(outline: $0) }
        self.puzzles = puzzlesPersistence.items ?? []
        puzzles.insert(PuzzleOutline(name: "empty", size: Size(width: 0, height: 0), outlines: []), at:0)  // Board0
        self.solutions = solutionsPersistence.items ?? [:]
        self.currentPuzzle = 1
        // set each piece's initial position
        initPiecesPositions()
    }
}

extension GameManager {
    private func initPiecesPositions() {
        for i in pieces.indices {
            let dx : Int = (i % 4) * 5
            let dy : Int = Int(floor(Double(i) / 4)) * 5
            pieces[i].position = Position(x: pieceBasePosition.x + dx, y: pieceBasePosition.y + dy)
        }
    }
    
    private func isPieceInDefault(_ piece : Piece) -> Bool {
        let i = pieces.firstIndex { $0.outline.name == piece.outline.name }!
        let piece = pieces[i]
        let dx : Int = (i % 4) * 5
        let dy : Int = Int(floor(Double(i) / 4)) * 5
        let position = Position(x: pieceBasePosition.x + dx, y: pieceBasePosition.y + dy, orientation: NumericOrientation(from: .up))
        return position.y == piece.position.y &&
                position.orientation.x == piece.position.orientation.x % 360 &&
                position.orientation.y == piece.position.orientation.y % 360 &&
                position.orientation.z == piece.position.orientation.z % 360
    }
    
    // Control buttons
    func setCurrentPuzzle(i : Int) {
        self.currentPuzzle = i
    }
    
    func reset() {
        initPiecesPositions()
    }
    
    func solve() {
        let puzzleName = puzzles[currentPuzzle].name
        let solution = solutions[puzzleName]
        pieces.indices.forEach{ i in
            let pentominoName = pieces[i].outline.name
            let position = solution![pentominoName]
            pieces[i].position.moveTo(position!)
        }
    }
    
    // Getters
    func getBoardPosition() -> Position {
        return Position(x: 0, y: 0)
    }
    
    func getButtonSize() -> Size {
        return Size(width: 3, height: 3)
    }
    
    func getBoardSize() -> Size {
        return Size(width: 14, height: 14)
    }
    
    // View Functions    
    func isCorrect(_ piece: Piece) -> Bool {
        
        if currentPuzzle == 0 {return false}
        
        let pentominoName = piece.outline.name
        let position = currentSolution[pentominoName]!
        return  position.x == piece.position.x &&
                position.y == piece.position.y &&
                position.orientation.x == piece.position.orientation.x % 360 &&
                position.orientation.y == piece.position.orientation.y % 360 &&
                position.orientation.z == piece.position.orientation.z % 360
    }
    
}
