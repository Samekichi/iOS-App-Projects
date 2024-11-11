//
//  Grid.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/17/23.
//

import SwiftUI

struct Grid : Shape {
    
    let m : Int
    let n : Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let spacing = rect.height / CGFloat(m)
        // Row lines
        for y in stride(from: 0, through: rect.height, by: spacing) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        // Column lines
        for x in stride(from: 0, through: rect.width, by: spacing) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        return path
    }
}


struct Grid_Previews: PreviewProvider {
    static var previews: some View {
        let spacing = CGFloat(100)
        Grid(m:2, n:3)
            .stroke(Color.blue, lineWidth: 5)
            .frame(width: 3*spacing, height: 2*spacing)
        Grid(m:6, n:4)
            .stroke(Color.blue, lineWidth: 5)
            .frame(width: 4*spacing, height: 6*spacing)
        Grid(m:1, n:1)
            .stroke(Color.blue, lineWidth: 5)
            .frame(width: 1*spacing, height: 1*spacing)
    }
}
