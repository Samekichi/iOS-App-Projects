//
//  BoardButtonsView.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/17/23.
//

import SwiftUI

struct BoardButtonsView: View {
    
    @EnvironmentObject var manager : GameManager
    let boardRange : ClosedRange<Int>
    var unitSize : Size  {manager.getButtonSize()}
    var realSize : CGSize  {manager.getRealSize(unitSize)}
    
    var body: some View {
        VStack {
            ForEach(boardRange, id: \.self) { i in
                Button(action: {
                    manager.setCurrentPuzzle(i: i)
                    withAnimation { manager.reset() }
                }) {
                    Image("Board\(i)Button")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: realSize.width, height: realSize.height)
                        .border(manager.currentPuzzle == i ? const.shadowColor : Color.clear, width: 4)
                        .shadow(color: manager.currentPuzzle == i ? const.shadowColor : Color.clear, radius: 15)
                    
                }
                .opacity(const.buttonOpacity)
            }
        }
        .padding()
    }
}

//struct BoardButtonsView_Previews: PreviewProvider {
//    static var previews: some View {
//        BoardButtonsView()
//    }
//}
