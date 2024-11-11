//
//  OrientationTest.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/21/23.
//

import SwiftUI

struct OrientationTest: View {
    var body: some View {
        Image("OrientationTest")
            // right
//            .rotation3DEffect(.degrees(0), axis: (x: 1, y: 0, z: 0))
//            .rotation3DEffect(.degrees(0), axis: (x: 0, y: 1, z: 0))
//            .rotation3DEffect(.degrees(90), axis: (x: 0, y: 0, z: 1))
            // upMirrored
//            .rotation3DEffect(.degrees(0), axis: (x: 1, y: 0, z: 0))
//            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
//            .rotation3DEffect(.degrees(0), axis: (x: 0, y: 0, z: 1))
            // leftMirrored
            .rotation3DEffect(.degrees(0), axis: (x: 1, y: 0, z: 0))
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            .rotation3DEffect(.degrees(-90), axis: (x: 0, y: 0, z: 1))
    }
}

#Preview {
    OrientationTest()
}
