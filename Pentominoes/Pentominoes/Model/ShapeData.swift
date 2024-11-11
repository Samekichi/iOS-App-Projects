//
//  ShapeData.swift
//  Grids
//
//  Created by Hannan, John Joseph on 1/5/23.
//

// Model structs for Pentomino Pieces and Puzzle outlines.  Used for reading in from the JSON files (PiecesData.json & PuzzlesData.json)

import Foundation

// Point is a model struct corresponding to CGPoint but working on unit (Int) coordinates
struct Point : Codable {
    let x : Int
    let y : Int
}

// Size is a model struct corresponding to CGSize but working on unit (Int) coordinates
struct Size : Codable {
    let width : Int
    let height : Int
}

// The data needed to construct a Pentomino piece.  The rows & columns specify exactly how many unit squares the piece requires (e.g., 1 column, 5 rows for "I").  The outline is a sequence of coordinates in a rows x columns space, with (0,0) in the upper left.
struct PentominoOutline : Codable, Identifiable{
    let name : String
    let size : Size
    let outline : [Point]
    var id : String {name}
}

// The data needed to construct a Puzzle shape.  The rows & columns specify exactly how many unit squares the piece requires (e.g., 1 column, 5 rows for "I").  The outlines is an array of sequences of coordinates in a rows x columns space, with (0,0) in the upper left.  Each sequence defines a path.  This allows for "holes" to appear in a puzzle shape
struct PuzzleOutline : Codable, Identifiable{
    let name : String  // Used to identify matching Solution in Solutons data
    let size : Size
    let outlines : [[Point]] //multiple subpaths
    var id : String {name}
    
}
