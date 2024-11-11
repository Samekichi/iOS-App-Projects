//
//  Pentomino.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/17/23.
//

import SwiftUI

struct Pentomino: Shape {
    
    let pentomino : PentominoOutline
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let m : Int = pentomino.size.height
//        let n = pentomino.cgSize.width
        let spacing = rect.height / CGFloat(m)

        let outline : [Point] = pentomino.outline
        let start = outline.first!
        path.move(to: CGPoint(x: start.x * Int(spacing), y: start.y * Int(spacing)))
        
        for point in outline.dropFirst() {
            path.addLine(to: CGPoint(x: point.x * Int(spacing), y: point.y * Int(spacing)))
        }
        
        return path
    }
}


struct Pentomino_Previews: PreviewProvider {
    static var previews: some View {
        
        let spacing = CGFloat(100)
        Pentomino(
            pentomino: PentominoOutline(name: "I", size: Size(width: 1, height: 5), outline: [Point(x:0, y:0), Point(x:1, y:0), Point(x:1, y:5), Point(x:0, y:5), Point(x:0, y:0)])
        )
        .stroke(Color.blue, lineWidth: 5)
        .frame(width: spacing*1, height: spacing*5)
        
        Pentomino(
            pentomino: PentominoOutline(name: "Y", size: Size(width: 2, height: 4), outline: [Point(x:0, y:0), Point(x:1, y:0), Point(x:1, y:1), Point(x:2, y:1), Point(x:2, y:2), Point(x:1, y:2), Point(x:1, y:4), Point(x:0, y:4), Point(x:0, y:0)])
        )
        .stroke(Color.blue, lineWidth: 5)
        .frame(width: spacing*2, height: spacing*4)
        
        Pentomino(
            pentomino: PentominoOutline(name: "N", size: Size(width: 2, height: 4), outline: [Point(x:0, y:0), Point(x:1, y:0), Point(x:1, y:2), Point(x:2, y:2), Point(x:2, y:4), Point(x:1, y:4), Point(x:1, y:3), Point(x:0, y:3), Point(x:0, y:0)])
        )
        .stroke(Color.blue, lineWidth: 5)
        .frame(width: spacing*2, height: spacing*4)
    }
}
