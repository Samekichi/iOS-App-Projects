//
//  PieceView.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/17/23.
//

import SwiftUI

struct PieceView: View {
    
    @EnvironmentObject var manager : GameManager
    @Binding var piece : Piece
    
    @State var scale : CGFloat = 1.0
    @State var offset : CGSize = CGSize.zero
    @State var isDragged : Bool = false
    @State var isSelected : Bool = false
    @State var isShaded : Bool = false
    @State var isCorrect : Bool = false
    
    var pentominoOutline : PentominoOutline {piece.outline}
    var unitSize : Size {pentominoOutline.size}
    var realSize : CGSize {manager.getRealSize(unitSize)}
    var unitPosition : Position {piece.position}
    var realPosition : CGPoint {manager.getRealPosition(for: unitPosition, with: unitSize)}
    
    
    var body: some View {
        
        // Gestures
        let tap = TapGesture(count: 1)
            .onEnded{
                withAnimation(.easeInOut) {
                    if !isDragged {
                        // Rotate 90 deg CW
                        piece.position.rotateBy(90, direction: .cw)
                        //                    rotation += 90
                        isSelected = false
                        isCorrect = manager.isCorrect(piece)
                    }
                }
            }
        let longPress = LongPressGesture(minimumDuration: 0.75)
            .onChanged{ _ in
                withAnimation(.easeInOut) {
                    isSelected = true
                }
            }
            .onEnded{ _ in
                withAnimation(.easeInOut) {
                    if !isDragged {
                        // Flip by 180 deg along vertical (y) axis
                        piece.position.flip()
                        isSelected = false
                        isCorrect = manager.isCorrect(piece)
                    }
                }
            }
        let drag = DragGesture()
            .onChanged{ value in
                withAnimation(.linear) {
                    // update view offset
                    offset = value.translation
                    scale = 1.2
                    isShaded = true
                    isSelected = true
                    isDragged = true
                }
            }
            .onEnded{ value in
                withAnimation(.linear) {
                    // update piece position
                    let unitMove = manager.getUnitMove(of: value.translation)
                    piece.position.moveBy(unitMove)
                    offset = CGSize.zero
                    
                    scale = 1.0
                    isShaded = false
                    isSelected = false
                    isDragged = false
                    isCorrect = manager.isCorrect(piece)
                }
            }
        
        // View
        PentominoView(pentominoOutline: pentominoOutline, color: Color(of: piece), isSelected: isSelected, isCorrect: isCorrect)
            .opacity(isDragged ? 0.5 : isCorrect ? 0.5 : 1.0)
            .rotation3DEffect(.degrees(Double(piece.position.orientation.x)), axis: (x: 1, y: 0, z: 0))
            .rotation3DEffect(.degrees(Double(piece.position.orientation.y)), axis: (x: 0, y: 1, z: 0))
            .rotation3DEffect(.degrees(Double(piece.position.orientation.z)), axis: (x: 0, y: 0, z: 1))
            .scaleEffect(CGSize(width: scale, height: scale))
            .shadow(color: isShaded ? const.shadowColor : Color.clear, radius: 10)
            .position(realPosition)
            .offset(offset)
            .gesture(
                tap
                .simultaneously(with: longPress)
                .simultaneously(with: drag)
            )
            .onChange(of: piece.position) {
                withAnimation(.easeInOut) {
                    isCorrect = manager.isCorrect(piece)
                }
            }
            .onChange(of: manager.currentPuzzle) {
                withAnimation(.easeInOut) {
                    isCorrect = manager.isCorrect(piece)
                }
            }
    }
}


struct PieceView_Previews: PreviewProvider {
    static var previews: some View {
        PieceView(piece: .constant(Piece(
            outline: PentominoOutline(name: "Y", size: Size(width: 2, height: 4), outline: [Point(x:0, y:0), Point(x:1, y:0), Point(x:1, y:1), Point(x:2, y:1), Point(x:2, y:2), Point(x:1, y:2), Point(x:1, y:4), Point(x:0, y:4), Point(x:0, y:0)]), position: Position(x: 3, y: 18))
        ))
        .environmentObject(GameManager())
    }
}
