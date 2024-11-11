//
//  ScoreView.swift
//  Spelling Challenge
//
//  Created by Andrew Wu on 8/27/23.
//

import SwiftUI

struct ScoreView: View {
    let score : Int
    var body: some View {
        Text("\(score)")
            .font(.title)
            .bold()
            .padding(25)
    }
}
