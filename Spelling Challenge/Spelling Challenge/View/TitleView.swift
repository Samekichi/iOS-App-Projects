//
//  TitleView.swift
//  Spelling Challenge
//
//  Created by Andrew Wu on 8/26/23.
//
import SwiftUI

struct TitleView: View {
    let title : String
    var body: some View {
        Text("\(title.trimmingCharacters(in: .whitespacesAndNewlines).uppercased())")
            .font(.largeTitle)
            .bold().padding()
        Spacer()
    }
}
