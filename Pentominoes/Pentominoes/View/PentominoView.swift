//
//  PentominoView.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/17/23.
//

import SwiftUI

struct PentominoView: View {
    
    @EnvironmentObject var manager : GameManager
    let pentominoOutline : PentominoOutline
    let color : Color
    var isSelected : Bool
    var isCorrect : Bool
    var unitSize : Size {pentominoOutline.size}
    var realSize : CGSize {manager.getRealSize(unitSize)}
    
    var body: some View {
        Group {
            // Outline
            Pentomino(pentomino: pentominoOutline)
                .stroke(isSelected || isCorrect ? const.selectedOutlineColor : const.outlineColor, lineWidth: const.outlineWidth)
                .frame(width: realSize.width, height: realSize.height)
            // Fill
            Pentomino(pentomino: pentominoOutline)
                .fill(color)
                .overlay(
                    Grid(m: unitSize.height, n: unitSize.width)
                        .stroke(isSelected || isCorrect ? const.selectedOutlineColor : const.outlineColor, lineWidth: const.outlineWidth)
                        .clipShape(Pentomino(pentomino: pentominoOutline))
                )
                .frame(width: realSize.width, height: realSize.height)
        }
    }
}


struct PentominoView_Previews: PreviewProvider {
    static var previews: some View {
        PentominoView(pentominoOutline: PentominoOutline(name: "Y", size: Size(width: 2, height: 4), outline: [Point(x:0, y:0), Point(x:1, y:0), Point(x:1, y:1), Point(x:2, y:1), Point(x:2, y:2), Point(x:1, y:2), Point(x:1, y:4), Point(x:0, y:4), Point(x:0, y:0)]), color: .gray, isSelected: false, isCorrect: false
        )
        .environmentObject(GameManager())
    }
}
