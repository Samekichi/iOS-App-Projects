//
//  Piece.swift
//  Pentominoes
//
//  Created by Hannan, John Joseph on 9/5/23.
//

import Foundation



// Each piece is fully determined by its outline and its position

struct Piece : Identifiable {
    let outline : PentominoOutline 

    var position : Position = Position()
    var id : String { outline.name }
}
