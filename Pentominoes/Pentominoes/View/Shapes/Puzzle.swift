//
//  Puzzle.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/17/23.
//

import SwiftUI

struct Puzzle : Shape {
    
    let puzzle : PuzzleOutline
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let m = puzzle.size.height
//        let n = puzzle.cgSize.width
        let spacing = rect.height / CGFloat(m)

        let cgOutlines : [[Point]] = puzzle.outlines
        for outline in cgOutlines {
            var subPath = Path()
            
            let start = outline.first!
            subPath.move(to: CGPoint(x: start.x * Int(spacing), y: start.y * Int(spacing)))
            
            for point in outline.dropFirst() {
                subPath.addLine(to: CGPoint(x: point.x * Int(spacing), y: point.y * Int(spacing)))
            }
            path.addPath(subPath)
        }
        
        return path
    }
}


struct Puzzle_Previews: PreviewProvider {
    static var previews: some View {
        
        let spacing = CGFloat(50)
        
        Puzzle(puzzle:
            PuzzleOutline(
                name: "6x10",
                size: Size(width: 10, height: 6),
                outlines: [
                    [Point(x: 0, y: 0), Point(x: 10, y: 0), Point(x: 10, y: 6), Point(x: 0, y: 6), Point(x: 0, y: 0)]
                ]
            )
        )
        .stroke(Color.blue, lineWidth: 5)
        .frame(width: spacing*10, height: spacing*6)
        
        Puzzle(puzzle:
            PuzzleOutline(
                name: "5x12",
                size: Size(width: 12, height: 6),
                outlines: [
                    [Point(x: 0, y: 0), Point(x: 12, y: 0), Point(x: 12, y: 5), Point(x: 0, y: 5), Point(x: 0, y: 0)]
                ]
            )
        )
        .stroke(Color.blue, lineWidth: 5)
        .frame(width: spacing*12, height: spacing*6)
        
        Puzzle(puzzle:
            PuzzleOutline(
                name: "5x12",
                size: Size(width: 8, height: 8),
                outlines: [
                    [Point(x: 0, y: 0), Point(x: 8, y: 0), Point(x: 8, y: 8), Point(x: 0, y: 8), Point(x: 0, y: 0)],
                    [Point(x: 3, y: 3), Point(x: 5, y: 3), Point(x: 5, y: 5), Point(x: 3, y: 5), Point(x: 3, y: 3)]
                ]
            )
        )
        .stroke(Color.blue, lineWidth: 5)
        .frame(width: spacing*8, height: spacing*8)
        
        Puzzle(puzzle:
            PuzzleOutline(
                name: "FourHoles",
                size: Size(width: 8, height: 8),
                outlines: [
                    [Point(x: 0, y: 0), Point(x: 8, y: 0), Point(x: 8, y: 8), Point(x: 0, y: 8), Point(x: 0, y: 0)],
                    [Point(x: 1, y: 1), Point(x: 2, y: 1), Point(x: 2, y: 2), Point(x: 1, y: 2), Point(x: 1, y: 1)],
                    [Point(x: 6, y: 1), Point(x: 7, y: 1), Point(x: 7, y: 2), Point(x: 6, y: 2), Point(x: 6, y: 1)],
                    [Point(x: 6, y: 6), Point(x: 7, y: 6), Point(x: 7, y: 7), Point(x: 6, y: 7), Point(x: 6, y: 6)],
                    [Point(x: 1, y: 6), Point(x: 2, y: 6), Point(x: 2, y: 7), Point(x: 1, y: 7), Point(x: 1, y: 6)]
                ]
            )
        )
        .stroke(Color.blue, lineWidth: 5)
        .frame(width: spacing*8, height: spacing*8)
    }
}

