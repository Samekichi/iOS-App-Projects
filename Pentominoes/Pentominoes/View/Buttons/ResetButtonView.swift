//
//  ResetButtonView.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/17/23.
//

import SwiftUI

struct ResetButtonView: View {
    @EnvironmentObject var manager : GameManager
    
    var body: some View {
        Button("Reset") {
            withAnimation(.easeInOut) {manager.reset()}
        }
            .font(.largeTitle)
            .padding()
            .foregroundColor(.white)
            .background(RoundedRectangle(cornerRadius: 10)
                            .fill(.blue))
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(const.outlineColor, lineWidth: const.outlineWidth)
                .opacity(const.boardOpacity))
            .disabled(manager.isAllPiecesInDefault)
            .opacity(manager.isAllPiecesInDefault ? const.disableOpacity : const.buttonOpacity)
            .animation(.easeInOut, value: manager.isAllPiecesInDefault)
    }
}
